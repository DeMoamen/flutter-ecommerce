-- ========================================
-- E-Commerce Database Schema for Supabase
-- Run this in Supabase SQL Editor
-- ========================================

-- ── 1. Products: Add rating column if missing ──────────────────────────────
ALTER TABLE products ADD COLUMN IF NOT EXISTS rating DECIMAL(3, 2) DEFAULT 0.0;

-- ── 2. Product Reviews Table ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT DEFAULT 'مستخدم',
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS user_name TEXT DEFAULT 'مستخدم';
ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS rating DECIMAL(2, 1) NOT NULL DEFAULT 5.0;
ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS comment TEXT DEFAULT '';

CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_user_id ON product_reviews(user_id);

-- ── 3. Banners Table ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT DEFAULT '',
    image_url TEXT DEFAULT '',
    link_url TEXT DEFAULT '',
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE banners ADD COLUMN IF NOT EXISTS title TEXT DEFAULT '';
ALTER TABLE banners ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT '';
ALTER TABLE banners ADD COLUMN IF NOT EXISTS link_url TEXT DEFAULT '';
ALTER TABLE banners ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE banners ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;
ALTER TABLE banners ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_banners_active_order ON banners(is_active, display_order);

-- ── 5. Categories Table ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    icon_name TEXT DEFAULT 'category',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(name)
);

ALTER TABLE categories ADD COLUMN IF NOT EXISTS name TEXT NOT NULL DEFAULT 'عام';
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon_name TEXT DEFAULT 'category';

-- Insert default categories if table is empty
INSERT INTO categories (name, icon_name)
SELECT 'أحذية', 'directions_run'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'أحذية');

INSERT INTO categories (name, icon_name)
SELECT 'ملابس', 'checkroom'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'ملابس');

INSERT INTO categories (name, icon_name)
SELECT 'إلكترونيات', 'laptop'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'إلكترونيات');

INSERT INTO categories (name, icon_name)
SELECT 'ساعات', 'watch'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'ساعات');

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view categories" ON categories;
CREATE POLICY "Anyone can view categories"
    ON categories FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Admin can manage categories" ON categories;
CREATE POLICY "Admin can manage categories"
    ON categories FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

-- ── 4. Cart Items Table ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);

-- ── 2. Wishlist Items Table ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wishlist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_wishlist_items_user_id ON wishlist_items(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_items_product_id ON wishlist_items(product_id);

-- ── 3. Orders Table ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'Processing',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- ── 4. Order Items Table ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- ========================================
-- Row Level Security (RLS) Policies
-- ========================================

-- ── Enable RLS on all tables ──────────────────────────────────────────────
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- ── Cart Items Policies ───────────────────────────────────────────────────
DROP POLICY IF EXISTS "Users can view their own cart items" ON cart_items;
CREATE POLICY "Users can view their own cart items"
    ON cart_items FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own cart items" ON cart_items;
CREATE POLICY "Users can insert their own cart items"
    ON cart_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own cart items" ON cart_items;
CREATE POLICY "Users can update their own cart items"
    ON cart_items FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own cart items" ON cart_items;
CREATE POLICY "Users can delete their own cart items"
    ON cart_items FOR DELETE
    USING (auth.uid() = user_id);

-- ── Wishlist Items Policies ───────────────────────────────────────────────
DROP POLICY IF EXISTS "Users can view their own wishlist items" ON wishlist_items;
CREATE POLICY "Users can view their own wishlist items"
    ON wishlist_items FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own wishlist items" ON wishlist_items;
CREATE POLICY "Users can insert their own wishlist items"
    ON wishlist_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own wishlist items" ON wishlist_items;
CREATE POLICY "Users can delete their own wishlist items"
    ON wishlist_items FOR DELETE
    USING (auth.uid() = user_id);

-- ── Orders Policies ───────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;
CREATE POLICY "Users can view their own orders"
    ON orders FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own orders" ON orders;
CREATE POLICY "Users can insert their own orders"
    ON orders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own orders" ON orders;
CREATE POLICY "Users can update their own orders"
    ON orders FOR UPDATE
    USING (auth.uid() = user_id);

-- ── Order Items Policies ──────────────────────────────────────────────────
DROP POLICY IF EXISTS "Users can view their own order items" ON order_items;
CREATE POLICY "Users can view their own order items"
    ON order_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can insert their own order items" ON order_items;
CREATE POLICY "Users can insert their own order items"
    ON order_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- ── Product Reviews Policies ──────────────────────────────────────────────
DROP POLICY IF EXISTS "Users can view reviews for a product" ON product_reviews;
CREATE POLICY "Users can view reviews for a product"
    ON product_reviews FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can insert their own review" ON product_reviews;
CREATE POLICY "Users can insert their own review"
    ON product_reviews FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own review" ON product_reviews;
CREATE POLICY "Users can update their own review"
    ON product_reviews FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own review" ON product_reviews;
CREATE POLICY "Users can delete their own review"
    ON product_reviews FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admin can manage all reviews" ON product_reviews;
CREATE POLICY "Admin can manage all reviews"
    ON product_reviews FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

-- ── Banners Policies ───────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Anyone can view active banners" ON banners;
CREATE POLICY "Anyone can view active banners"
    ON banners FOR SELECT
    USING (is_active = true);

DROP POLICY IF EXISTS "Admin can manage banners" ON banners;
CREATE POLICY "Admin can manage banners"
    ON banners FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

-- ========================================
-- Admin Policies (allow admin to view all)
-- ========================================
DROP POLICY IF EXISTS "Admin can view all cart items" ON cart_items;
CREATE POLICY "Admin can view all cart items"
    ON cart_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Admin can view all wishlist items" ON wishlist_items;
CREATE POLICY "Admin can view all wishlist items"
    ON wishlist_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Admin can view all orders" ON orders;
CREATE POLICY "Admin can view all orders"
    ON orders FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Admin can view all order items" ON order_items;
CREATE POLICY "Admin can view all order items"
    ON order_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Admin can view all product reviews" ON product_reviews;
CREATE POLICY "Admin can view all product reviews"
    ON product_reviews FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Admin can manage all banners" ON banners;
CREATE POLICY "Admin can manage all banners"
    ON banners FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.uid = auth.uid()
            AND users.user_role = 'admin'
        )
    );

-- ========================================
-- Auto-update product rating trigger
-- ========================================
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET rating = (
        SELECT COALESCE(ROUND(AVG(rating)::NUMERIC, 1), 0.0)
        FROM product_reviews
        WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)
    )
    WHERE id = COALESCE(NEW.product_id, OLD.product_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_product_rating
AFTER INSERT OR UPDATE OR DELETE ON product_reviews
FOR EACH ROW EXECUTE FUNCTION update_product_rating();
