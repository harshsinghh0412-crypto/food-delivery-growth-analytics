# Food Delivery Growth & Operations Analytics

An end-to-end business analytics project analyzing customer behavior, revenue growth, restaurant performance, and delivery operations using **MySQL and Power BI**.

---

## 📌 Project Overview

This project analyzes a food delivery platform's transactional data to understand:

- Revenue and order growth
- Customer behavior and retention
- Customer value and RFM segmentation
- Restaurant and cuisine performance
- City-level business performance
- Delivery efficiency
- Order failures and operational bottlenecks
- Acquisition channel performance

The project follows an end-to-end analytics workflow:

**Raw Data → Data Quality → SQL Analysis → Analytical Views → Power BI Dashboard → Business Insights**

---

## 🛠️ Tools & Technologies

- **MySQL** — Data analysis, aggregation, joins, CTEs, window functions, analytical views
- **Power BI** — Interactive dashboards and KPI visualization
- **DAX** — Measures and calculated metrics
- **Excel/CSV** — Source datasets
- **GitHub** — Project documentation and version control

---

## 📊 Dataset

The dataset contains approximately:

- **100,000 orders**
- **10,000 customers**
- **500 restaurants**
- **2,000 delivery partners**
- **91,068 delivered orders**

### Data Period

**January 2025 – June 2026**

### Main Tables

| Table | Description |
|---|---|
| `customers` | Customer demographics and acquisition information |
| `restaurants` | Restaurant, cuisine, rating and pricing information |
| `orders` | Order transactions, values, status, discounts and ratings |
| `delivery_partners` | Delivery partner and vehicle information |
| `order_delivery` | Delivery distance and timing information |

---

# 📈 Power BI Dashboard

The Power BI dashboard contains five analytical pages.

## 1. Executive Overview

Provides a high-level view of overall business performance.

### KPIs

- Total GMV: **₹47.76M**
- Total Orders: **100K**
- Overall AOV: **₹524.42**
- Average Delivery Time: **~25.3 minutes**

### Analysis

- Monthly GMV trend
- Monthly order volume
- Order status breakdown
- GMV by city
- Customer acquisition channels

---

## 2. Customer Analytics

Analyzes customer behavior and customer value.

### Analysis

- Customer RFM segmentation
- Average spend by customer segment
- Customer value by acquisition channel
- Repeat vs one-time customers
- Customer spending behavior

### Key Metrics

- Total Customers: **10K**
- Repeat Customers: **9,987**
- One-time Customers: **13**
- Average Customer Spend: **~₹4,776**

---

## 3. Restaurant Analytics

Analyzes restaurant-level performance.

### Analysis

- Top restaurants by GMV
- GMV by cuisine
- Restaurant rating vs delivered orders
- Restaurant order volume
- Restaurant customer ratings

### KPIs

- Total Restaurants: **500**
- Average Orders per Restaurant: **~182**
- Average Restaurant Rating: **~4.4/5**

---

## 4. Operations Analytics

Analyzes delivery performance and operational efficiency.

### KPIs

- Delivered Orders: **91.07K**
- Average Delivery Time: **25.30 minutes**
- Average Delivery Distance: **4.40 km**
- Average Customer Rating: **~4.43/5**

### Analysis

- Delivery time by city
- Order failure rate by city
- Delivery time by distance
- Delivery time by vehicle type
- Delivery partner performance

---

## 5. Growth & Strategy

Analyzes customer acquisition and growth patterns.

### Analysis

- GMV by acquisition channel
- Average customer spend by city
- Customer value by RFM segment
- Monthly GMV growth

---

# 🔍 Key Business Findings

### 1. Stable overall business performance

The platform generated approximately **₹47.76M GMV** from **100K orders**, with an overall AOV of approximately **₹524**.

Monthly order and GMV volumes remained relatively stable throughout the analysis period.

---

### 2. High proportion of delivered orders

Approximately **91.07% of orders were delivered**.

Order outcomes:

| Status | Orders | Share |
|---|---:|---:|
| Delivered | 91,068 | 91.07% |
| Cancelled | 6,415 | 6.42% |
| Rejected | 2,517 | 2.52% |

---

### 3. Customer base shows strong repeat activity

The analysis identified **9,987 customers with at least two delivered orders**, compared with 13 customers with only one delivered order.

This indicates that the dataset contains substantial repeat-order activity and supports deeper customer segmentation analysis.

---

### 4. Customer value varies across RFM segments

The RFM analysis identifies groups such as:

- Champions
- Loyal Customers
- Recent Customers
- At Risk
- Others

Champions and Loyal Customers represent high-frequency/high-value customer groups, while At Risk customers provide a useful segment for retention analysis.

---

### 5. Bangalore generates the highest city-level GMV

Among the analyzed cities, Bangalore generated approximately **₹8.66M GMV**, followed by Delhi and Mumbai.

City-level performance was also analyzed using:

- Order volume
- GMV
- AOV
- Failure rate
- Average delivery time

---

### 6. Delivery operations are relatively consistent

Overall average delivery time was approximately **25.3 minutes**, while average delivery distance was approximately **4.4 km**.

Delivery performance was analyzed across:

- Cities
- Vehicle types
- Distance bands
- Delivery partners
- Time of day
- Day of week

---

# 🧠 SQL Analysis

The project contains six SQL analysis files:

```text
sql/
├── 01_data_quality.sql
├── 02_business_analysis.sql
├── 03_customer_analysis.sql
├── 04_restaurant_analysis.sql
├── 05_operations_analysis.sql
└── 06_views.sql
