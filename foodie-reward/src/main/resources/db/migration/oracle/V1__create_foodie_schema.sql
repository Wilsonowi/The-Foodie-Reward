CREATE TABLE memberships (
    mem_id VARCHAR2(5) PRIMARY KEY,
    tier_id VARCHAR2(3) NOT NULL,
    join_date VARCHAR2(10) NOT NULL,
    status VARCHAR2(10) NOT NULL,
    CONSTRAINT ck_membership_status CHECK (status IN ('Active', 'Inactive'))
);

CREATE TABLE customers (
    cust_id NUMBER(5) PRIMARY KEY,
    cust_name VARCHAR2(80) NOT NULL,
    phone_num VARCHAR2(20) NOT NULL,
    cust_email VARCHAR2(100) NOT NULL UNIQUE,
    mem_id VARCHAR2(5) NOT NULL,
    total_paid NUMBER(10,2) DEFAULT 0 NOT NULL,
    transaction_count NUMBER(6) DEFAULT 0 NOT NULL,
    CONSTRAINT fk_customer_membership FOREIGN KEY (mem_id) REFERENCES memberships(mem_id)
);

CREATE TABLE point_accounts (
    cust_id NUMBER(5) PRIMARY KEY,
    mem_id VARCHAR2(5) NOT NULL,
    points_balance NUMBER(8) DEFAULT 0 NOT NULL,
    point_status VARCHAR2(20) NOT NULL,
    total_points_earned NUMBER(8) DEFAULT 0 NOT NULL,
    total_points_used NUMBER(8) DEFAULT 0 NOT NULL,
    CONSTRAINT ck_point_status CHECK (point_status IN ('Active', 'Expiry')),
    CONSTRAINT fk_point_customer FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    CONSTRAINT fk_point_membership FOREIGN KEY (mem_id) REFERENCES memberships(mem_id)
);

CREATE TABLE reward_catalogs (
    catalog_id VARCHAR2(5) PRIMARY KEY,
    catalog_name VARCHAR2(80) NOT NULL,
    catalog_description VARCHAR2(255) NOT NULL,
    is_active NUMBER(1) NOT NULL,
    CONSTRAINT ck_catalog_active CHECK (is_active IN (0, 1))
);

CREATE TABLE rewards (
    reward_id VARCHAR2(5) PRIMARY KEY,
    reward_name VARCHAR2(100) NOT NULL,
    points_required NUMBER(8) NOT NULL,
    reward_type VARCHAR2(30) NOT NULL,
    stock NUMBER(8) DEFAULT 0 NOT NULL,
    catalog_id VARCHAR2(5) NOT NULL,
    last_restock VARCHAR2(10) NOT NULL,
    CONSTRAINT ck_reward_points CHECK (points_required > 0),
    CONSTRAINT ck_reward_stock CHECK (stock >= 0),
    CONSTRAINT fk_reward_catalog FOREIGN KEY (catalog_id) REFERENCES reward_catalogs(catalog_id)
);

CREATE TABLE reward_transactions (
    transaction_id VARCHAR2(5) PRIMARY KEY,
    transaction_type VARCHAR2(10) NOT NULL,
    points_earned NUMBER(8) DEFAULT 0 NOT NULL,
    points_redeemed NUMBER(8) DEFAULT 0 NOT NULL,
    transaction_date VARCHAR2(10) NOT NULL,
    transaction_status VARCHAR2(10) NOT NULL,
    cust_id NUMBER(5) NOT NULL,
    CONSTRAINT ck_transaction_type CHECK (transaction_type IN ('Earn', 'Redeem')),
    CONSTRAINT ck_transaction_status CHECK (transaction_status IN ('Completed', 'Pending', 'Failed')),
    CONSTRAINT fk_transaction_customer FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TABLE redemptions (
    redemption_id VARCHAR2(5) PRIMARY KEY,
    cust_id NUMBER(5) NOT NULL,
    reward_id VARCHAR2(5) NOT NULL,
    redemption_date VARCHAR2(10) NOT NULL,
    status VARCHAR2(10) NOT NULL,
    transaction_id VARCHAR2(5),
    points_used NUMBER(8) DEFAULT 0 NOT NULL,
    CONSTRAINT ck_redemption_status CHECK (status IN ('Pending', 'Completed', 'Failed')),
    CONSTRAINT fk_redemption_customer FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    CONSTRAINT fk_redemption_reward FOREIGN KEY (reward_id) REFERENCES rewards(reward_id)
);

CREATE INDEX idx_transaction_status ON reward_transactions(transaction_status);
CREATE INDEX idx_redemption_status ON redemptions(status);
CREATE INDEX idx_reward_catalog ON rewards(catalog_id);
