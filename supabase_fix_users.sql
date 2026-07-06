-- حل مشكلة عدم ظهور المستخدمين للأدمن
-- هذه الدالة تتجاوز قيود الحماية (RLS) بأمان وتعيد كل المستخدمين إذا كان الطالب أدمن

CREATE OR REPLACE FUNCTION get_admin_users_list()
RETURNS SETOF users AS $$
BEGIN
  -- التحقق مما إذا كان المستخدم الحالي لديه صلاحية أدمن
  IF EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin') THEN
    RETURN QUERY SELECT * FROM users ORDER BY created_at DESC;
  ELSE
    -- إذا لم يكن أدمن، يرى نفسه فقط
    RETURN QUERY SELECT * FROM users WHERE uid = auth.uid();
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
