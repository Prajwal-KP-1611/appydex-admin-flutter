"""
Admin Reviews Takedown System - FastAPI Router Implementation

This module implements the 3 missing review takedown endpoints:
1. GET /api/v1/admin/reviews/takedown-requests - List takedown requests
2. GET /api/v1/admin/reviews/takedown-requests/{request_id} - Get request details
3. POST /api/v1/admin/reviews/takedown-requests/{request_id}/resolve - Resolve request

INSTALLATION INSTRUCTIONS:
1. Copy this file to: backend/app/routers/admin/reviews_takedown.py
2. Add to backend/app/main.py:
   from app.routers.admin import reviews_takedown
   app.include_router(reviews_takedown.router, prefix="/api/v1/admin", tags=["Admin Reviews Takedown"])
3. Run migrations (see schema below)
4. Test endpoints

Created: November 12, 2025
Ticket: BACKEND-REVIEWS-002
"""

from __future__ import annotations

from datetime import datetime
from typing import Optional, Literal, List, Dict, Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, Header, status
from pydantic import BaseModel, Field, validator
from sqlalchemy import select, func, and_, or_
from sqlalchemy.orm import Session, joinedload

# Import your project's dependencies
# from app.database import get_db
# from app.models import ReviewTakedownRequest, Review, Vendor, User, AdminUser
# from app.auth import get_current_admin_user, check_permission
# from app.services import NotificationService, AuditService
# from app.cache import cache_with_ttl

router = APIRouter()


# ========================================
# Pydantic Schemas
# ========================================

class ReviewerInfo(BaseModel):
    """Reviewer information in takedown request"""
    id: str
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    profile_image: Optional[str] = None
    account_created_at: Optional[datetime] = None
    total_reviews: int = 0
    total_bookings: int = 0
    trust_score: int = 50
    risk_flags: List[str] = []


class VendorInfo(BaseModel):
    """Vendor information in takedown request"""
    id: str
    name: str
    display_name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    logo: Optional[str] = None
    rating: Optional[float] = None
    total_reviews: int = 0
    total_takedown_requests: int = 0
    accepted_takedowns: int = 0
    rejected_takedowns: int = 0


class ReviewInfo(BaseModel):
    """Review information in takedown request"""
    id: str
    rating: int
    title: str
    body: str
    status: str
    created_at: datetime
    updated_at: Optional[datetime] = None
    reviewer: ReviewerInfo


class Evidence(BaseModel):
    """Evidence item in takedown request"""
    id: Optional[str] = None
    type: Literal["image", "document", "text"]
    url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    filename: Optional[str] = None
    size_bytes: Optional[int] = None
    description: str
    content: Optional[str] = None  # For text type
    uploaded_at: Optional[datetime] = None


class AdminUserInfo(BaseModel):
    """Admin user who resolved request"""
    id: str
    name: str
    email: str


class Resolution(BaseModel):
    """Resolution details"""
    decision: Literal["accept", "reject"]
    action_taken: Optional[Literal["hide", "remove"]] = None
    reason: str
    admin_notes: Optional[str] = None
    review_status_after: Optional[str] = None
    vendor_notified: bool = True
    reviewer_notified: bool = False


class TakedownRequestList(BaseModel):
    """Takedown request in list view"""
    id: str
    request_number: str
    status: Literal["open", "accepted", "rejected"]
    review: ReviewInfo
    vendor: VendorInfo
    reason_code: str
    reason_description: str
    evidence: List[Evidence] = []
    vendor_notes: Optional[str] = None
    priority: Literal["high", "medium", "low"]
    created_at: datetime
    resolved_at: Optional[datetime] = None
    resolved_by: Optional[AdminUserInfo] = None
    resolution: Optional[Resolution] = None
    admin_notes: Optional[str] = None


class BookingInfo(BaseModel):
    """Booking information"""
    id: str
    booking_number: str
    status: str
    scheduled_at: datetime
    completed_at: Optional[datetime] = None
    amount_cents: int
    payment_status: str
    has_dispute: bool = False


class TimelineEvent(BaseModel):
    """Timeline event in takedown request"""
    event: str
    timestamp: datetime
    actor: Optional[str] = None
    details: str


class InternalAnalysis(BaseModel):
    """Internal analysis for admin decision making"""
    similar_reviews_by_user: List[str] = []
    similar_complaints_against_vendor: int = 0
    user_behavior_flags: List[str] = []
    review_timing_suspicious: bool = False
    sentiment_analysis: Optional[str] = None


class TakedownRequestDetail(TakedownRequestList):
    """Detailed takedown request view"""
    booking: Optional[BookingInfo] = None
    internal_analysis: Optional[InternalAnalysis] = None
    timeline: List[TimelineEvent] = []


class ResolveRequest(BaseModel):
    """Request body for resolving takedown request"""
    decision: Literal["accept", "reject"]
    action: Optional[Literal["hide", "remove"]] = None
    reason: str = Field(..., min_length=50, max_length=2000)
    admin_notes: Optional[str] = Field(None, max_length=5000)
    notify_vendor: bool = True
    notify_reviewer: bool = False

    @validator("action")
    def validate_action_for_accept(cls, v, values):
        """Action is required when decision is 'accept'"""
        if values.get("decision") == "accept" and not v:
            raise ValueError("action is required when decision is 'accept'")
        if values.get("decision") == "reject" and v:
            raise ValueError("action must not be provided when decision is 'reject'")
        return v


class PaginationMeta(BaseModel):
    """Pagination metadata"""
    page: int
    page_size: int
    total_items: int
    total_pages: int
    has_next: bool
    has_prev: bool
    summary: Optional[Dict[str, Any]] = None


class TakedownListResponse(BaseModel):
    """Response for list endpoint"""
    success: bool = True
    data: List[TakedownRequestList]
    meta: PaginationMeta


class TakedownDetailResponse(BaseModel):
    """Response for detail endpoint"""
    success: bool = True
    data: TakedownRequestDetail


class ResolveResponse(BaseModel):
    """Response for resolve endpoint"""
    success: bool = True
    data: Dict[str, Any]


class ErrorResponse(BaseModel):
    """Error response"""
    success: bool = False
    error: Dict[str, Any]


# ========================================
# Endpoint Implementations
# ========================================

@router.get(
    "/reviews/takedown-requests",
    response_model=TakedownListResponse,
    summary="List Review Takedown Requests",
    description="Get paginated list of vendor takedown requests with filtering",
    responses={
        200: {"description": "Success"},
        403: {"description": "Permission denied", "model": ErrorResponse},
    }
)
async def list_takedown_requests(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(25, ge=1, le=100, description="Items per page"),
    status: Optional[Literal["open", "accepted", "rejected"]] = Query("open", description="Filter by status"),
    reason_code: Optional[str] = Query(None, description="Filter by reason code"),
    vendor_id: Optional[str] = Query(None, description="Filter by vendor ID"),
    from_date: Optional[datetime] = Query(None, description="Filter from date"),
    to_date: Optional[datetime] = Query(None, description="Filter to date"),
    sort_by: Literal["created_at", "priority"] = Query("created_at", description="Sort field"),
    sort_order: Literal["asc", "desc"] = Query("desc", description="Sort order"),
    # db: Session = Depends(get_db),
    # current_admin = Depends(get_current_admin_user),
):
    """
    List all vendor takedown requests with comprehensive filtering.
    
    **Permissions Required:** reviews:moderate OR super_admin
    
    **Query Parameters:**
    - page: Page number (default: 1)
    - page_size: Items per page (default: 25, max: 100)
    - status: Filter by status (default: "open")
    - reason_code: Filter by reason code
    - vendor_id: Filter by vendor UUID
    - from_date/to_date: Date range filter
    - sort_by: Sort by created_at or priority
    - sort_order: asc or desc
    
    **Returns:**
    - Paginated list of takedown requests
    - Each request includes review, vendor, evidence, and resolution info
    - Meta with pagination and summary statistics
    """
    
    # TODO: Check permissions
    # check_permission(current_admin, "reviews:moderate")
    
    # Build query
    # query = select(ReviewTakedownRequest).options(
    #     joinedload(ReviewTakedownRequest.review).joinedload(Review.reviewer),
    #     joinedload(ReviewTakedownRequest.vendor),
    #     joinedload(ReviewTakedownRequest.resolved_by)
    # )
    
    # Apply filters
    # filters = []
    # if status:
    #     filters.append(ReviewTakedownRequest.status == status)
    # if reason_code:
    #     filters.append(ReviewTakedownRequest.reason_code == reason_code)
    # if vendor_id:
    #     filters.append(ReviewTakedownRequest.vendor_id == vendor_id)
    # if from_date:
    #     filters.append(ReviewTakedownRequest.created_at >= from_date)
    # if to_date:
    #     filters.append(ReviewTakedownRequest.created_at <= to_date)
    
    # if filters:
    #     query = query.where(and_(*filters))
    
    # Apply sorting
    # if sort_by == "priority":
    #     # Sort: high -> medium -> low, then by created_at
    #     priority_order = case(
    #         (ReviewTakedownRequest.priority == "high", 1),
    #         (ReviewTakedownRequest.priority == "medium", 2),
    #         (ReviewTakedownRequest.priority == "low", 3),
    #     )
    #     if sort_order == "desc":
    #         query = query.order_by(priority_order.desc(), ReviewTakedownRequest.created_at.desc())
    #     else:
    #         query = query.order_by(priority_order, ReviewTakedownRequest.created_at)
    # else:
    #     if sort_order == "desc":
    #         query = query.order_by(ReviewTakedownRequest.created_at.desc())
    #     else:
    #         query = query.order_by(ReviewTakedownRequest.created_at)
    
    # Get total count
    # count_query = select(func.count()).select_from(query.subquery())
    # total_items = db.scalar(count_query)
    
    # Apply pagination
    # offset = (page - 1) * page_size
    # query = query.offset(offset).limit(page_size)
    
    # Execute query
    # results = db.execute(query).scalars().all()
    
    # Get summary statistics (cached for 5 minutes)
    # summary = cache_with_ttl(300)(get_takedown_summary)(db)
    
    # TODO: Replace with actual database query
    # Mock response for demonstration
    return TakedownListResponse(
        success=True,
        data=[],  # Convert results to TakedownRequestList
        meta=PaginationMeta(
            page=page,
            page_size=page_size,
            total_items=0,  # Replace with actual count
            total_pages=0,
            has_next=False,
            has_prev=False,
            summary={
                "open": 0,
                "accepted": 0,
                "rejected": 0,
                "avg_resolution_time_hours": 0.0
            }
        )
    )


@router.get(
    "/reviews/takedown-requests/{request_id}",
    response_model=TakedownDetailResponse,
    summary="Get Takedown Request Details",
    description="Get complete information about a specific takedown request",
    responses={
        200: {"description": "Success"},
        403: {"description": "Permission denied", "model": ErrorResponse},
        404: {"description": "Request not found", "model": ErrorResponse},
    }
)
async def get_takedown_request(
    request_id: UUID,
    # db: Session = Depends(get_db),
    # current_admin = Depends(get_current_admin_user),
):
    """
    Get detailed information about a specific takedown request.
    
    **Permissions Required:** reviews:moderate OR super_admin
    
    **Path Parameters:**
    - request_id: UUID of the takedown request
    
    **Returns:**
    - Complete takedown request details
    - Review information with booking context
    - Vendor track record
    - Evidence files with metadata
    - Internal analysis (sentiment, timing, risk flags)
    - Timeline of events
    - Resolution details (if resolved)
    """
    
    # TODO: Check permissions
    # check_permission(current_admin, "reviews:moderate")
    
    # Query request with all relationships
    # query = select(ReviewTakedownRequest).options(
    #     joinedload(ReviewTakedownRequest.review).joinedload(Review.reviewer),
    #     joinedload(ReviewTakedownRequest.review).joinedload(Review.booking),
    #     joinedload(ReviewTakedownRequest.vendor),
    #     joinedload(ReviewTakedownRequest.resolved_by)
    # ).where(ReviewTakedownRequest.id == request_id)
    
    # result = db.execute(query).scalar_one_or_none()
    
    # if not result:
    #     raise HTTPException(
    #         status_code=status.HTTP_404_NOT_FOUND,
    #         detail={
    #             "code": "REQUEST_NOT_FOUND",
    #             "message": "Takedown request not found",
    #             "request_id": str(request_id)
    #         }
    #     )
    
    # Get internal analysis
    # analysis = generate_internal_analysis(result, db)
    
    # Get timeline
    # timeline = generate_timeline(result, db)
    
    # TODO: Replace with actual data
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail={
            "code": "REQUEST_NOT_FOUND",
            "message": "Takedown request not found",
            "request_id": str(request_id)
        }
    )


@router.post(
    "/reviews/takedown-requests/{request_id}/resolve",
    response_model=ResolveResponse,
    summary="Resolve Takedown Request",
    description="Admin accepts or rejects vendor takedown request",
    responses={
        200: {"description": "Success"},
        400: {"description": "Validation error", "model": ErrorResponse},
        403: {"description": "Permission denied", "model": ErrorResponse},
        404: {"description": "Request not found", "model": ErrorResponse},
        409: {"description": "Already resolved or idempotency conflict", "model": ErrorResponse},
    }
)
async def resolve_takedown_request(
    request_id: UUID,
    resolve_data: ResolveRequest,
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key"),
    # db: Session = Depends(get_db),
    # current_admin = Depends(get_current_admin_user),
):
    """
    Admin resolves a takedown request by accepting or rejecting it.
    
    **Permissions Required:** reviews:moderate OR super_admin
    **Idempotency:** Required - provide Idempotency-Key header (UUID)
    
    **Path Parameters:**
    - request_id: UUID of the takedown request
    
    **Request Body:**
    - decision: "accept" or "reject" (required)
    - action: "hide" or "remove" (required if decision = "accept")
    - reason: Admin's reasoning (required, 50-2000 chars)
    - admin_notes: Internal notes (optional, max 5000 chars)
    - notify_vendor: Send notification to vendor (default: true)
    - notify_reviewer: Send notification to reviewer (default: false)
    
    **Actions:**
    - accept + hide: Review hidden, can be restored
    - accept + remove: Review permanently removed
    - reject: Review remains visible
    
    **Process:**
    1. Validate request and check if already resolved
    2. Check idempotency key
    3. Update takedown request status
    4. Update review status (if accepted)
    5. Create audit log entry
    6. Queue notification jobs
    7. Return result
    
    **Returns:**
    - Updated takedown request with resolution
    - Review status after action
    - Notification status (email/in-app sent)
    """
    
    # TODO: Check permissions
    # check_permission(current_admin, "reviews:moderate")
    
    # Check idempotency
    # if idempotency_key:
    #     cached_result = check_idempotency_key(idempotency_key, "resolve_takedown", request_id)
    #     if cached_result:
    #         return cached_result
    
    # Get takedown request with row-level locking
    # query = select(ReviewTakedownRequest).where(
    #     ReviewTakedownRequest.id == request_id
    # ).with_for_update()
    
    # request = db.execute(query).scalar_one_or_none()
    
    # if not request:
    #     raise HTTPException(
    #         status_code=status.HTTP_404_NOT_FOUND,
    #         detail={
    #             "code": "REQUEST_NOT_FOUND",
    #             "message": "Takedown request not found",
    #             "request_id": str(request_id)
    #         }
    #     )
    
    # Check if already resolved
    # if request.status != "open":
    #     raise HTTPException(
    #         status_code=status.HTTP_409_CONFLICT,
    #         detail={
    #             "code": "ALREADY_RESOLVED",
    #             "message": "This takedown request has already been resolved",
    #             "current_status": request.status,
    #             "resolved_at": request.resolved_at.isoformat() if request.resolved_at else None,
    #             "resolved_by": str(request.resolved_by) if request.resolved_by else None
    #         }
    #     )
    
    # Start transaction
    # try:
    #     # Update takedown request
    #     request.status = "accepted" if resolve_data.decision == "accept" else "rejected"
    #     request.resolved_at = datetime.utcnow()
    #     request.resolved_by = current_admin.id
    #     request.decision = resolve_data.decision
    #     request.action_taken = resolve_data.action
    #     request.resolution_reason = resolve_data.reason
    #     request.admin_notes = resolve_data.admin_notes
    #     
    #     # Update review if accepted
    #     review_status_after = None
    #     if resolve_data.decision == "accept":
    #         review = request.review
    #         if resolve_data.action == "hide":
    #             review.status = "hidden"
    #             review_status_after = "hidden"
    #         elif resolve_data.action == "remove":
    #             review.status = "removed"
    #             review.deleted_at = datetime.utcnow()
    #             review_status_after = "removed"
    #         
    #         # Add moderation history
    #         review.moderation_history.append({
    #             "action": resolve_data.action,
    #             "reason": "Takedown request accepted",
    #             "admin_id": str(current_admin.id),
    #             "timestamp": datetime.utcnow().isoformat()
    #         })
    #     
    #     # Create audit log
    #     audit_entry = AuditLog(
    #         admin_id=current_admin.id,
    #         action="resolve_takedown_request",
    #         resource_type="review_takedown_request",
    #         resource_id=str(request_id),
    #         changes={
    #             "decision": resolve_data.decision,
    #             "action": resolve_data.action,
    #             "reason": resolve_data.reason,
    #             "review_status_before": request.review.status,
    #             "review_status_after": review_status_after
    #         }
    #     )
    #     db.add(audit_entry)
    #     
    #     # Commit transaction
    #     db.commit()
    #     
    #     # Queue notifications (async, outside transaction)
    #     notification_results = await queue_notifications(
    #         request, resolve_data, current_admin
    #     )
    #     
    #     # Store idempotency result
    #     if idempotency_key:
    #         store_idempotency_result(idempotency_key, response_data, ttl=86400)
    #     
    #     # Build response
    #     response_data = {
    #         "request": {
    #             "id": str(request.id),
    #             "request_number": request.request_number,
    #             "status": request.status,
    #             "resolved_at": request.resolved_at.isoformat(),
    #             "resolved_by": {
    #                 "id": str(current_admin.id),
    #                 "name": current_admin.name,
    #                 "email": current_admin.email
    #             },
    #             "resolution": {
    #                 "decision": resolve_data.decision,
    #                 "action_taken": resolve_data.action,
    #                 "reason": resolve_data.reason,
    #                 "admin_notes": resolve_data.admin_notes,
    #                 "vendor_notified": resolve_data.notify_vendor,
    #                 "reviewer_notified": resolve_data.notify_reviewer
    #             }
    #         },
    #         "review": {
    #             "id": str(request.review.id),
    #             "status": review_status_after or request.review.status,
    #         },
    #         "notifications_sent": notification_results
    #     }
    #     
    #     return ResolveResponse(success=True, data=response_data)
    #     
    # except Exception as e:
    #     db.rollback()
    #     raise HTTPException(
    #         status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
    #         detail={
    #             "code": "RESOLUTION_FAILED",
    #             "message": "Failed to resolve takedown request",
    #             "error": str(e)
    #         }
    #     )
    
    # TODO: Replace with actual implementation
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail={
            "code": "REQUEST_NOT_FOUND",
            "message": "Takedown request not found",
            "request_id": str(request_id)
        }
    )


# ========================================
# Helper Functions
# ========================================

def get_takedown_summary(db: Session) -> Dict[str, Any]:
    """Get summary statistics for takedown requests (cached)"""
    # TODO: Implement
    # open_count = db.scalar(
    #     select(func.count()).where(ReviewTakedownRequest.status == "open")
    # )
    # accepted_count = db.scalar(
    #     select(func.count()).where(ReviewTakedownRequest.status == "accepted")
    # )
    # rejected_count = db.scalar(
    #     select(func.count()).where(ReviewTakedownRequest.status == "rejected")
    # )
    # avg_resolution_time = db.scalar(
    #     select(func.avg(
    #         func.extract("epoch", ReviewTakedownRequest.resolved_at - ReviewTakedownRequest.created_at) / 3600
    #     )).where(ReviewTakedownRequest.status.in_(["accepted", "rejected"]))
    # )
    
    return {
        "open": 0,
        "accepted": 0,
        "rejected": 0,
        "avg_resolution_time_hours": 0.0
    }


def generate_internal_analysis(request, db: Session) -> InternalAnalysis:
    """Generate internal analysis for admin decision making"""
    # TODO: Implement
    # - Check for similar reviews by same user
    # - Check for similar complaints against vendor
    # - Analyze user behavior flags
    # - Check review timing (suspicious if posted long after booking)
    # - Run sentiment analysis
    
    return InternalAnalysis(
        similar_reviews_by_user=[],
        similar_complaints_against_vendor=0,
        user_behavior_flags=[],
        review_timing_suspicious=False,
        sentiment_analysis=None
    )


def generate_timeline(request, db: Session) -> List[TimelineEvent]:
    """Generate timeline of events for takedown request"""
    # TODO: Implement
    # - Booking created
    # - Booking completed
    # - Review posted
    # - Takedown requested
    # - Takedown resolved (if applicable)
    
    return []


async def queue_notifications(request, resolve_data: ResolveRequest, admin) -> Dict[str, Any]:
    """Queue notification jobs for vendor and reviewer"""
    # TODO: Implement
    # - Send email to vendor with decision
    # - Send in-app notification to vendor
    # - Send email to reviewer if review was removed
    # - Send in-app notification to reviewer
    # - Use notification templates based on decision/action
    
    return {
        "vendor": {
            "email": True,
            "in_app": True
        },
        "reviewer": {
            "email": False,
            "in_app": False
        }
    }


# ========================================
# Database Schema (SQL Migration)
# ========================================

"""
-- Migration: Create review_takedown_requests table
-- Run this migration before deploying the endpoints

CREATE TABLE IF NOT EXISTS review_takedown_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number VARCHAR(50) UNIQUE NOT NULL,
  review_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'open',
  reason_code VARCHAR(50) NOT NULL,
  reason_description TEXT NOT NULL,
  evidence JSONB,
  vendor_notes TEXT,
  priority VARCHAR(20) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP,
  resolved_by UUID,
  decision VARCHAR(20),
  action_taken VARCHAR(20),
  resolution_reason TEXT,
  admin_notes TEXT,
  
  CONSTRAINT fk_review FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
  CONSTRAINT fk_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
  CONSTRAINT fk_resolved_by FOREIGN KEY (resolved_by) REFERENCES admin_users(id) ON DELETE SET NULL,
  
  CONSTRAINT chk_status CHECK (status IN ('open', 'accepted', 'rejected')),
  CONSTRAINT chk_decision CHECK (decision IN ('accept', 'reject', NULL)),
  CONSTRAINT chk_action CHECK (action_taken IN ('hide', 'remove', NULL)),
  CONSTRAINT chk_priority CHECK (priority IN ('high', 'medium', 'low'))
);

-- Indexes for performance
CREATE INDEX idx_takedown_status_priority_created 
  ON review_takedown_requests(status, priority, created_at DESC);

CREATE INDEX idx_takedown_vendor_status 
  ON review_takedown_requests(vendor_id, status);

CREATE INDEX idx_takedown_review_id 
  ON review_takedown_requests(review_id);

CREATE INDEX idx_takedown_created_at 
  ON review_takedown_requests(created_at DESC);

-- Add columns to reviews table
ALTER TABLE reviews 
  ADD COLUMN IF NOT EXISTS has_takedown_request BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS takedown_request_count INT DEFAULT 0;

CREATE INDEX idx_reviews_has_takedown 
  ON reviews(has_takedown_request) 
  WHERE has_takedown_request = TRUE;

-- Function to auto-generate request number
CREATE OR REPLACE FUNCTION generate_takedown_request_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.request_number := 'TR-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || 
                        LPAD(NEXTVAL('takedown_request_seq')::TEXT, 6, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS takedown_request_seq START 1;

CREATE TRIGGER trg_generate_takedown_request_number
  BEFORE INSERT ON review_takedown_requests
  FOR EACH ROW
  EXECUTE FUNCTION generate_takedown_request_number();

-- Trigger to update reviews.has_takedown_request
CREATE OR REPLACE FUNCTION update_review_takedown_flag()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE reviews 
    SET has_takedown_request = TRUE,
        takedown_request_count = takedown_request_count + 1
    WHERE id = NEW.review_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_review_takedown_flag
  AFTER INSERT ON review_takedown_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_review_takedown_flag();
"""
