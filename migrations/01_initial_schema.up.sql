CREATE TABLE IF NOT EXISTS users
(
    id SERIAL,
    fname VARCHAR(100) NOT NULL,
    CHECK (length(trim(fname)) > 0),
    lname VARCHAR(100) NOT NULL,
    CHECK (length(trim(lname)) > 0),
    password_hash TEXT NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

-- shop cart of user 1:1
CREATE TABLE IF NOT EXISTS shop_cart
(
    user_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    locked_price NUMERIC,
    lock_exp_date TIMESTAMPTZ,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS user_addresses
(
    id INT NOT NULL,
    user_id INT NOT NULL,
    province VARCHAR(100) NOT NULL,
    CHECK (length(trim(province)) > 0),
    city VARCHAR(100) NOT NULL,
    CHECK (length(trim(city)) > 0),
    street TEXT NOT NULL,
    CHECK (length(trim(street)) > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS support
(
    id SERIAL,
    fname VARCHAR(100) NOT NULL,
    CHECK (length(trim(fname)) > 0),
    lname VARCHAR(100) NOT NULL,
    CHECK (length(trim(lname)) > 0),
    password_hash TEXT NOT NULL,
    image_url TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS student_verify_requests
(
	id INT NOT NULL,
	user_id INT UNIQUE NOT NULL,
	support_id INT UNIQUE NOT NULL,
	status BIT(1), -- null -> pending, 0 -> rejected, 1 -> accepted
	PRIMARY KEY (id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (support_id) REFERENCES support(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS students
(
	user_id INT NOT NULL,
	student_verify_request_id INT NOT NULL,
	PRIMARY KEY (user_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (student_verify_request_id) REFERENCES student_verify_requests(id) ON DELETE CASCADE
	-- TODO assertion to check student_verify_request_id status bit is set to 1 (accepted)
);


CREATE TABLE IF NOT EXISTS rejected_student_verify_requests
(
	cause VARCHAR(160) NOT NULL,
	student_verify_request_id INT NOT NULL,
	PRIMARY	KEY (cause, student_verify_request_id),
	FOREIGN KEY (student_verify_request_id) REFERENCES student_verify_requests(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS student_verify_request_documents
(
	document_hash BIT(256) NOT NULL,
	request_id INT NOT NULL,
	PRIMARY KEY (document_hash, request_id),
	FOREIGN KEY (request_id) REFERENCES student_verify_requests(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_create_requests
(
	id INT NOT NULL,
	user_id INT UNIQUE NOT NULL,
	support_id INT UNIQUE NOT NULL,
	status BIT(1), -- null -> pending, 0 -> rejected, 1 -> accepted
	PRIMARY KEY (id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (support_id) REFERENCES support(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rejected_shop_create_requests
(
	cause VARCHAR(160) NOT NULL,
	shop_create_request_id INT NOT NULL,
	PRIMARY	KEY (cause, shop_create_request_id),
	FOREIGN KEY (shop_create_request_id) REFERENCES shop_create_requests(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_create_request_documents
(
	document_hash BIT(256) NOT NULL,
	request_id INT NOT NULL,
	PRIMARY KEY (document_hash, request_id),
	FOREIGN KEY (request_id) REFERENCES shop_create_requests(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop
(
    id SERIAL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
	credit_card CHAR(16) NOT NULL,
    is_pro BOOLEAN NOT NULL, -- pro or individual
    status VARCHAR(50),
    CHECK (status IN ('pending','active','suspended','banned')),
	request_id INT UNIQUE NOT NULL,
    PRIMARY KEY (id),
	FOREIGN KEY (request_id) REFERENCES shop_create_requests(id) ON DELETE CASCADE
);

-- TODO assertion to check shop_create_request_id status is accepted (set to 1)

CREATE TABLE IF NOT EXISTS workmate_apply_requests
(
	id INT NOT NULL,
	user_id INT UNIQUE NOT NULL,
	shop_id INT UNIQUE NOT NULL,
	status BIT(1), -- null -> pending, 0 -> rejected, 1 -> accepted
	PRIMARY KEY (id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rejected_workmate_apply_requests
(
	cause VARCHAR(160) NOT NULL,
	workmate_request_id INT NOT NULL,
	PRIMARY	KEY (cause, workmate_request_id),
	FOREIGN KEY (workmate_request_id) REFERENCES workmate_apply_requests(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS workmates
(
	request_id INT UNIQUE NOT NULL,
	is_fired BOOLEAN NOT NULL,
	permission BIT(2) NOT NULL, -- 00 -> change all products + change info
								-- 01 -> change info
								-- 10 -> change own products
								-- 11 -> change own products + change info
	FOREIGN KEY (request_id) REFERENCES workmate_apply_requests(id) ON DELETE CASCADE
	-- TODO constraints for adding/removing product & changing shop info
);

CREATE TABLE IF NOT EXISTS user_bookmarks_shop
(
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    PRIMARY KEY (user_id, shop_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE
);

-- Base table: Product (weak entity of Shop)
CREATE TABLE IF NOT EXISTS product
(
    id INT NOT NULL,
    shop_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    -- created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    product_type VARCHAR(50) NOT NULL,
    CHECK (product_type IN ('goods','service')),
	added_by INT NOT NULL, -- 0 -> shop owner
    PRIMARY KEY (shop_id, id),
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE,
	FOREIGN KEY (added_by) REFERENCES workmates(request_id) ON DELETE CASCADE
);

-- Product images table
CREATE TABLE IF NOT EXISTS product_images
(
    id INT NOT NULL,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    image_url TEXT NOT NULL,
    PRIMARY KEY (shop_id, product_id, id),
    FOREIGN KEY (shop_id, product_id) REFERENCES product(shop_id, id) ON DELETE CASCADE
);

-- Specialization from Product: Goods
CREATE TABLE IF NOT EXISTS goods
(
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    price NUMERIC NOT NULL,
    CHECK (price > 0),
    PRIMARY KEY (shop_id, product_id),
    FOREIGN KEY (shop_id, product_id) REFERENCES product(shop_id, id) ON DELETE CASCADE
);

-- Specialization from Product: Service
CREATE TABLE IF NOT EXISTS service
(
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (shop_id, product_id),
    FOREIGN KEY (shop_id, product_id) REFERENCES product(shop_id, id) ON DELETE CASCADE
);

-- Disjoint subtype: Not Required Scheduling Service
CREATE TABLE IF NOT EXISTS not_required_scheduling
(
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    price NUMERIC NOT NULL,
    CHECK (price > 0),
    PRIMARY KEY (shop_id, product_id),
    FOREIGN KEY (shop_id, product_id) REFERENCES service(shop_id, product_id) ON DELETE CASCADE
);

-- Disjoint subtype: Required Scheduling Service
CREATE TABLE IF NOT EXISTS required_scheduling
(
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (shop_id, product_id),
    FOREIGN KEY (shop_id, product_id) REFERENCES service(shop_id, product_id) ON DELETE CASCADE
);

-- Weak entity: Time Table for Required Scheduling
CREATE TABLE IF NOT EXISTS time_table
(
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    price_per_hour NUMERIC NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CHECK (end_time > start_time),
    PRIMARY KEY (shop_id, product_id, date, start_time, end_time),
    FOREIGN KEY (shop_id, product_id) REFERENCES required_scheduling(shop_id, product_id) ON DELETE CASCADE
);

-- cart-item of shop_cart
CREATE TABLE IF NOT EXISTS cart_item
(
    id INT NOT NULL,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (user_id, id),

    FOREIGN KEY (user_id)
        REFERENCES shop_cart(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (shop_id, product_id)
        REFERENCES product(shop_id, id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_item_scheduled
(
    user_id INT NOT NULL,
    cart_item_id INT NOT NULL,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CHECK (end_time > start_time),

    PRIMARY KEY (user_id, cart_item_id),

    FOREIGN KEY (user_id, cart_item_id)
        REFERENCES cart_item(user_id, id)
        ON DELETE CASCADE,

    FOREIGN KEY (shop_id, product_id, date, start_time, end_time)
        REFERENCES time_table(shop_id, product_id, date, start_time, end_time)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_item_not_scheduled
(
    user_id INT NOT NULL,
    cart_item_id INT NOT NULL,

    PRIMARY KEY (user_id, cart_item_id),

    FOREIGN KEY (user_id, cart_item_id)
        REFERENCES cart_item(user_id, id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_bookmarks_product
(
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (user_id, shop_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id, product_id) REFERENCES product(shop_id, id) ON DELETE CASCADE
);

-- Weak entity: funnel of User
CREATE TABLE IF NOT EXISTS funnel
(
    user_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Shop page view: weak entity of funnel
CREATE TABLE IF NOT EXISTS shop_page_view
(
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    viewed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, shop_id, viewed_at),
    FOREIGN KEY (user_id) REFERENCES funnel(user_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE
);

-- Product page view: weak entity of funnel
CREATE TABLE IF NOT EXISTS product_page_view
(
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    viewed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, shop_id, product_id, viewed_at),
    FOREIGN KEY (user_id) REFERENCES funnel(user_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id, product_id) REFERENCES product(shop_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS discount_code
(
    code VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    discount_type VARCHAR(50) NOT NULL,
    value INT,
    percent INT,
    user_id INT,
    shop_id INT,
    support_id INT,

    PRIMARY KEY (code),

    CHECK (discount_type IN ('value','percent')),

    CHECK (
        (discount_type = 'value' AND value IS NOT NULL AND percent IS NULL)
        OR
        (discount_type = 'percent' AND percent IS NOT NULL AND value IS NULL)
    ),

    CHECK (value IS NULL OR value > 0),
    CHECK (percent IS NULL OR (percent > 0 AND percent <= 100)),

    CHECK (support_id IS NOT NULL OR shop_id IS NOT NULL),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE,
    FOREIGN KEY (support_id) REFERENCES support(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_plan
(
    id SERIAL,
    support_id INT NOT NULL,
    duration INT NOT NULL,
    price NUMERIC NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (id),
    FOREIGN KEY (support_id) REFERENCES support(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_plan
(
    id SERIAL,
    support_id INT NOT NULL,
    duration INT NOT NULL,
    price NUMERIC NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (id),
    FOREIGN KEY (support_id) REFERENCES support(id) ON DELETE CASCADE
);

CREATE TABLE transaction (
    id              SERIAL PRIMARY KEY,
    user_id         INT NOT NULL,
    amount          NUMERIC NOT NULL CHECK (amount > 0),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    type            VARCHAR(20) NOT NULL CHECK (type IN ('deposit','withdraw')),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS deposit
(
    transaction_id INT NOT NULL PRIMARY KEY,
    FOREIGN KEY (transaction_id) REFERENCES transaction(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS withdraw
(
    transaction_id INT NOT NULL,
    pays_for VARCHAR(50) NOT NULL,
    CHECK (pays_for IN ('shop_vip', 'user_vip', 'shop_request', 'order')),

    PRIMARY KEY (transaction_id),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_buys_vip_plan
(
    user_id INT NOT NULL,
    user_plan_id INT NOT NULL,
    exp_date DATE NOT NULL,
    withdraw_transaction_id INT NOT NULL,

    PRIMARY KEY (user_id, user_plan_id, exp_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_plan_id) REFERENCES user_plan(id) ON DELETE CASCADE,
    FOREIGN KEY (withdraw_transaction_id) REFERENCES withdraw(transaction_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_buys_vip_plan
(
    shop_id INT NOT NULL,
    shop_plan_id INT NOT NULL,
    exp_date DATE NOT NULL,
    withdraw_transaction_id INT NOT NULL,

    PRIMARY KEY (shop_id, shop_plan_id, exp_date),
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_plan_id) REFERENCES shop_plan(id) ON DELETE CASCADE,
    FOREIGN KEY (withdraw_transaction_id) REFERENCES withdraw(transaction_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_create_request_payments
(
	request_id INT UNIQUE NOT NULL,
	transaction_id INT UNIQUE NOT NULL,
	FOREIGN KEY (request_id) REFERENCES shop_create_requests(id) ON DELETE CASCADE,
	FOREIGN KEY (transaction_id) REFERENCES withdraw(transaction_id) ON DELETE CASCADE
	-- TODO check if withdraw is for shop_request
);

CREATE TABLE IF NOT EXISTS orders
(
    id SERIAL,
    user_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    amount          NUMERIC NOT NULL CHECK (amount > 0),

    PRIMARY KEY (user_id, id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_item
(
    id SERIAL,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    review TEXT,

    PRIMARY KEY (user_id, order_id, id),
    FOREIGN KEY (user_id, order_id) REFERENCES orders(user_id, id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id, product_id) REFERENCES product(shop_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS badge
(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image_url TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS review_has_badge
(
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    badge_id INT NOT NULL,

    PRIMARY KEY (order_item_id, badge_id),
    FOREIGN KEY (user_id, order_id, order_item_id) REFERENCES order_item(user_id, order_id, id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badge(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS shop_cart_checkout_order
(
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    transaction_id INT NOT NULL,
    checkout_address TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (user_id, order_id),
    FOREIGN KEY (user_id, order_id) REFERENCES orders(user_id, id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transaction(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_message_shop
(
    id SERIAL,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    text TEXT,
    file_url TEXT,
    
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS support_awards_badge
(
    support_id INT NOT NULL,
    badge_id INT NOT NULL,
    shop_id INT NOT NULL,
    awarded_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (support_id, badge_id, shop_id, awarded_at),

    FOREIGN KEY (support_id) REFERENCES support(id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badge(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_posts_story
(
    id INT NOT NULL,
    shop_id INT NOT NULL,
    posted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    text TEXT,
    media_url TEXT,
    PRIMARY KEY (shop_id, id),
    FOREIGN KEY (shop_id) REFERENCES shop(id) ON DELETE CASCADE
);
