-- حل مشكلة عدم تحديث صلاحية المستخدم بسبب قواعد الحماية (RLS)
-- تم إزالة الإشارة لجدول profiles لأنه غير موجود في قاعدة البيانات لديك

CREATE OR REPLACE FUNCTION update_user_role(target_user_id UUID, new_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  -- التحقق مما إذا كان المستخدم الحالي لديه صلاحية أدمن
  IF EXISTS (SELECT 1 FROM users WHERE uid = auth.uid() AND user_role = 'admin') THEN
    
    -- تحديث دور المستخدم في جدول users
    UPDATE users 
    SET user_role = new_role 
    WHERE uid = target_user_id;
    
    RETURN TRUE;
  ELSE
    -- المستخدم ليس أدمن أو لا يملك صلاحية
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
