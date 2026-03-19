INSERT INTO customers (customer_id, risk_tier, factors) VALUES
    (
        'a1b2c3d4-0001-0001-0001-000000000001',
        'LOW',
        '[{"factor_code":"LOW_TRANSACTION_VOLUME","factor_description":"Customer transaction volume is below risk threshold"}]'
    )
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO customers (customer_id, risk_tier, factors) VALUES
    (
        'a1b2c3d4-0002-0002-0002-000000000002',
        'MEDIUM',
        '[{"factor_code":"IRREGULAR_ACTIVITY","factor_description":"Irregular transaction patterns detected"},{"factor_code":"PARTIAL_KYC","factor_description":"KYC documentation incomplete"}]'
    )
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO customers (customer_id, risk_tier, factors) VALUES
    (
        'a1b2c3d4-0003-0003-0003-000000000003',
        'HIGH',
        '[{"factor_code":"HIGH_DEBT_RATIO","factor_description":"Debt to income ratio exceeds acceptable threshold"},{"factor_code":"MISSED_PAYMENTS","factor_description":"Three or more missed payments in the last 12 months"}]'
    )
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO customers (customer_id, risk_tier, factors) VALUES
    (
        'a1b2c3d4-0004-0004-0004-000000000004',
        'HIGH',
        NULL
    )
ON CONFLICT (customer_id) DO NOTHING;
