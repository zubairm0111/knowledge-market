# 🎓 Knowledge Market - Decentralized Expertise Marketplace

## Overview

**Knowledge Market** is a revolutionary production-ready Clarity smart contract that creates a decentralized marketplace for trading verified knowledge and expertise. Unlike traditional platforms that take huge cuts (30-50%), Knowledge Market charges only 5% while giving experts full control over their intellectual property and earnings through blockchain transparency.

## 🎯 The Revolutionary Concept

### Why Knowledge Market Changes Everything:

**Traditional Problems:**
- ❌ Platforms take 30-50% commission (Udemy, Skillshare, etc.)
- ❌ Content censorship and arbitrary removals
- ❌ Fake reviews and manipulated ratings
- ❌ Opaque revenue sharing
- ❌ No ownership of your reputation
- ❌ Platform lock-in (can't take followers elsewhere)

**Knowledge Market Solutions:**
- ✅ Only 5% platform fee (transparent on-chain)
- ✅ Uncensorable content (blockchain storage)
- ✅ Verifiable purchases and authentic reviews
- ✅ Transparent earnings and ratings
- ✅ Portable reputation (on-chain forever)
- ✅ Expert ownership and control

## 🌟 Innovative Features

### 1. **Reputation-Based Dynamic Pricing**
- Base price set by expert
- Automatic price boost based on ratings (+rating%)
- Demand-based pricing (+purchases/200%)
- Market-driven valuation
- High-quality experts earn premium rates

**Example:**
```
Base Price: 10 STX
Average Rating: 4.8/5 → +48% = 14.8 STX
Total Purchases: 100 → +50% = 22.2 STX
Final Dynamic Price: 22.2 STX
```

### 2. **Comprehensive Rating System**
- 5-star rating scale (1-5)
- Written reviews (300 characters)
- Only verified purchasers can rate
- One rating per purchase
- Rating distribution tracking
- Average ratings for experts and listings

### 3. **Expert Profile System**
- Display name and bio
- Expertise areas declaration
- Total listings and sales tracking
- Lifetime earnings transparency
- Average rating display
- Verification badge (admin-approved)
- Join date and credibility history

### 4. **Advanced Statistics**
- **Per Expert:** Revenue, sales, active listings
- **Rating Distribution:** 5-star breakdown
- **Per Listing:** Purchases, revenue, ratings
- **Platform Wide:** Total volume, sales count
- **Optimized Queries:** Efficient data access

### 5. **Purchase Protection**
- One purchase per buyer per listing
- Immutable purchase records
- Timestamp verification
- Review authenticity guaranteed
- No duplicate reviews possible

### 6. **Expert Controls**
- Create up to 50 listings
- Update pricing anytime
- Activate/deactivate listings
- Update profile information
- View detailed statistics
- Track all purchases

## 💼 Real-World Use Cases

### 1. **Software Development Consultation**
```clarity
;; Register as expert
(contract-call? .knowledge-market register-expert
  u"Senior Blockchain Developer"
  u"10+ years experience in Clarity, Solidity, and Rust. Built 50+ production dApps. Specializing in DeFi protocols and NFT marketplaces."
  u"Blockchain, Smart Contracts, DeFi, NFTs, Security Audits")

;; Create consultation listing
(contract-call? .knowledge-market create-listing
  u"1-Hour Smart Contract Architecture Review"
  u"Detailed review of your contract architecture, security best practices, gas optimization, and recommendations for production deployment."
  "technology"
  u50000000  ;; 50 STX
  "video-call")
```

### 2. **Business Strategy Advice**
```clarity
(contract-call? .knowledge-market create-listing
  u"Startup GTM Strategy Session"
  u"Comprehensive go-to-market strategy for tech startups. Includes market analysis, positioning, pricing strategy, and 90-day execution plan."
  "business"
  u100000000  ;; 100 STX
  "consultation")
```

### 3. **Creative Services**
```clarity
(contract-call? .knowledge-market create-listing
  u"Professional Logo Design Consultation"
  u"1-hour brand identity consultation with portfolio review, mood boarding, and design direction for your project."
  "design"
  u30000000  ;; 30 STX
  "video-call")
```

### 4. **Legal Advice**
```clarity
(contract-call? .knowledge-market create-listing
  u"Crypto Legal Compliance Review"
  u"30-minute consultation on cryptocurrency regulations, tax implications, and compliance requirements for your jurisdiction."
  "legal"
  u75000000  ;; 75 STX
  "consultation")
```

### 5. **Educational Tutoring**
```clarity
(contract-call? .knowledge-market create-listing
  u"Advanced Mathematics Tutoring Session"
  u"1-hour personalized tutoring in calculus, linear algebra, or statistics. Homework help and exam preparation included."
  "education"
  u20000000  ;; 20 STX
  "video-call")
```

### 6. **Fitness Coaching**
```clarity
(contract-call? .knowledge-market create-listing
  u"Custom Workout & Nutrition Plan"
  u"Personalized 12-week training program with nutrition guidance, form videos, and progress tracking. Includes 2 check-in calls."
  "health"
  u80000000  ;; 80 STX
  "digital-delivery")
```

## 🏗️ Technical Architecture

### Core Data Structures

**Expert Profile**
```clarity
{
  display-name: string-utf8 50,      // Public name
  bio: string-utf8 500,              // Profile description
  expertise-areas: string-utf8 200,  // Skills/domains
  total-listings: uint,              // Listings created
  total-sales: uint,                 // Total purchases
  total-earned: uint,                // Lifetime earnings
  average-rating: uint,              // Overall rating (0-500)
  rating-count: uint,                // Number of ratings
  joined-at: uint,                   // Registration block
  is-verified: bool                  // Admin verification
}
```

**Knowledge Listing**
```clarity
{
  expert: principal,                 // Creator address
  title: string-utf8 100,            // Listing title
  description: string-utf8 500,      // Detailed description
  category: string-ascii 30,         // Category tag
  price: uint,                       // Base price in microSTX
  total-purchases: uint,             // Purchase count
  total-revenue: uint,               // Earnings from listing
  average-rating: uint,              // Listing rating (0-500)
  rating-count: uint,                // Number of ratings
  created-at: uint,                  // Creation block
  is-active: bool,                   // Active status
  delivery-type: string-ascii 20     // Delivery method
}
```

**Purchase Record**
```clarity
{
  purchase-price: uint,              // Price paid
  purchased-at: uint,                // Purchase block
  is-rated: bool,                    // Rating status
  rating: optional uint,             // Rating (1-5)
  review: optional string-utf8 300   // Written review
}
```

**Expert Statistics** (Optimized)
```clarity
{
  total-revenue: uint,               // Cumulative earnings
  completed-sales: uint,             // Sales count
  active-listings: uint,             // Active listing count
  five-star-count: uint,             // 5-star ratings
  four-star-count: uint,             // 4-star ratings
  three-star-count: uint,            // 3-star ratings
  two-star-count: uint,              // 2-star ratings
  one-star-count: uint               // 1-star ratings
}
```

## 📖 Complete Usage Guide

### For Experts

#### Step 1: Register as Expert
```clarity
(contract-call? .knowledge-market register-expert
  u"Dr. Sarah Chen"
  u"PhD in Computer Science from MIT. 15 years industry experience at Google and Coinbase. Passionate about teaching blockchain development."
  u"Blockchain, Clarity, Rust, System Design, Mentorship")
;; Returns: (ok true)
```

#### Step 2: Create Knowledge Listings
```clarity
(contract-call? .knowledge-market create-listing
  u"Smart Contract Security Audit"
  u"Comprehensive security review of your Clarity smart contracts. Includes vulnerability assessment, best practices review, and detailed report."
  "security"
  u100000000  ;; 100 STX base price
  "written-report")
;; Returns: (ok u1) - listing ID
```

#### Step 3: Manage Listings
```clarity
;; Update price based on demand
(contract-call? .knowledge-market update-listing-price u1 u150000000)

;; Temporarily deactivate (vacation mode)
(contract-call? .knowledge-market deactivate-listing u1)

;; Reactivate when ready
(contract-call? .knowledge-market reactivate-listing u1)

;; Update profile
(contract-call? .knowledge-market update-expert-profile
  u"Dr. Sarah Chen, PhD"
  u"Updated bio with new achievements..."
  u"Updated expertise areas...")
```

### For Buyers

#### Step 1: Browse and Purchase
```clarity
;; Check listing details
(contract-call? .knowledge-market get-listing u1)

;; Check dynamic price (includes reputation bonus)
(contract-call? .knowledge-market calculate-dynamic-price u1)

;; Purchase the knowledge
(contract-call? .knowledge-market purchase-listing u1)
;; Automatically transfers STX and records purchase
```

#### Step 2: Rate and Review
```clarity
(contract-call? .knowledge-market rate-listing
  u1                          ;; listing ID
  u5                          ;; rating (1-5 stars)
  u"Exceptional quality! Dr. Chen provided incredibly detailed feedback and caught several security issues I missed. Well worth the investment.")
;; Returns: (ok true)
```

### Query Functions

#### Check Expert Profile
```clarity
(contract-call? .knowledge-market get-expert 'ST1EXPERT...)
;; Returns complete expert profile
```

#### Check Expert Statistics
```clarity
(contract-call? .knowledge-market get-expert-stats 'ST1EXPERT...)
;; Returns revenue, sales, rating distribution
```

#### Verify Purchase
```clarity
(contract-call? .knowledge-market has-purchased u1 'ST1BUYER...)
;; Returns: (ok true) or (ok false)
```

#### Check Purchase Details
```clarity
(contract-call? .knowledge-market get-purchase u1 'ST1BUYER...)
;; Returns purchase record with rating/review
```

#### Platform Statistics
```clarity
(contract-call? .knowledge-market get-platform-stats)
;; Returns total listings, sales, volume, revenue
```

## 💰 Economic Model

### Fee Structure
- **Platform Fee:** 5% (500 basis points)
- **Expert Earnings:** 95% of sale price
- **Minimum Price:** 1 STX (prevents spam)
- **Maximum Listings:** 50 per expert

### Revenue Examples

**Example 1: 10 STX Listing**
