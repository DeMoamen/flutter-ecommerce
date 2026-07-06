-- السماح للأدمن برؤية جميع الطلبات وتعديلها

-- 1. إضافة سياسة السماح بقراءة الطلبات للمشرفين
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
CREATE POLICY "Admins can view all orders" 
ON orders FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
);

-- 2. إضافة سياسة السماح بتعديل الطلبات للمشرفين
DROP POLICY IF EXISTS "Admins can update all orders" ON orders;
CREATE POLICY "Admins can update all orders" 
ON orders FOR UPDATE 
USING (
  EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
);

-- 3. إضافة سياسة السماح بقراءة تفاصيل الطلب (order_items) للمشرفين
DROP POLICY IF EXISTS "Admins can view all order items" ON order_items;
CREATE POLICY "Admins can view all order items" 
ON order_items FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin')
);
