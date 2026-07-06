-- ============================================================
-- Admin Features SQL Setup
-- ============================================================

-- 1. Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  icon_name TEXT DEFAULT 'folder',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT USING (true);

CREATE POLICY "Only admins can insert categories"
  ON categories FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can update categories"
  ON categories FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can delete categories"
  ON categories FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

-- 2. Coupons table
CREATE TABLE IF NOT EXISTS coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  discount_percentage NUMERIC(5, 2) NOT NULL CHECK (discount_percentage > 0 AND discount_percentage <= 100),
  min_order_amount NUMERIC(10, 2) DEFAULT 0,
  max_uses INTEGER DEFAULT NULL,
  used_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ DEFAULT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active coupons"
  ON coupons FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins can view all coupons"
  ON coupons FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can insert coupons"
  ON coupons FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can update coupons"
  ON coupons FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can delete coupons"
  ON coupons FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

-- 3. Admin notifications table
CREATE TABLE IF NOT EXISTS admin_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  target_user_id UUID REFERENCES auth.users(id) DEFAULT NULL,
  is_sent BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE admin_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON admin_notifications FOR SELECT
  USING (
    target_user_id = auth.uid() OR target_user_id IS NULL
  );

CREATE POLICY "Only admins can insert notifications"
  ON admin_notifications FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can update notifications"
  ON admin_notifications FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

CREATE POLICY "Only admins can delete notifications"
  ON admin_notifications FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
  );

-- 4. Add category column to products if not exists
ALTER TABLE products ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'General';

-- 5. Add status column to orders if not exists (already there with default 'Processing')
-- Add updated_at to orders for tracking status changes
ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 6. Insert default categories
INSERT INTO categories (name, icon_name) VALUES
  ('أحذية', 'directions_run'),
  ('ملابس', 'checkroom'),
  ('ساعات', 'watch'),
  ('حقائب', 'shopping_bag')
ON CONFLICT DO NOTHING;

-- 7. Function to get analytics for admin
CREATE OR REPLACE FUNCTION get_admin_analytics()
RETURNS TABLE (
  total_products BIGINT,
  total_orders BIGINT,
  total_users BIGINT,
  total_revenue NUMERIC,
  pending_orders BIGINT,
  completed_orders BIGINT,
  active_coupons BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM products),
    (SELECT COUNT(*) FROM orders),
    (SELECT COUNT(*) FROM users WHERE user_role = 'user'),
    COALESCE((SELECT SUM(total_amount) FROM orders WHERE status != 'Cancelled'), 0),
    (SELECT COUNT(*) FROM orders WHERE status = 'Processing'),
    (SELECT COUNT(*) FROM orders WHERE status = 'Completed'),
    (SELECT COUNT(*) FROM coupons WHERE is_active = true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
