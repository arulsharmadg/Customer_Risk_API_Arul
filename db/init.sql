CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    risk_tier   VARCHAR(10) NOT NULL CHECK (risk_tier IN ('LOW', 'MEDIUM', 'HIGH')),
    factors     JSONB
);
