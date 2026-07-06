-- إصلاح مشكلة تسجيل المستخدمين ومزامنتهم مع جدول users
-- هذا السكربت يضمن أن كل من يسجل الدخول سيتم إضافته لجدول users مباشرة عبر قاعدة البيانات

-- 1. أولاً، نقوم بإضافة كل المستخدمين المسجلين مسبقاً في auth.users ولم يظهروا في جدول users
INSERT INTO public.users (uid, email, name, user_role, created_at)
SELECT 
  id, 
  email, 
  COALESCE(raw_user_meta_data->>'name', split_part(email, '@', 1)), 
  'user',
  created_at
FROM auth.users
WHERE id NOT IN (SELECT uid FROM public.users);

-- 2. تحديث الدالة التي تعمل تلقائياً عند تسجيل أي مستخدم جديد لتسجله في جدول users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (uid, email, name, user_role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    'user'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. ربط الدالة الجديدة بعملية التسجيل
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 4. إعطاء صلاحية الإضافة لجدول users لكي يستطيع التطبيق تحديث الاسم ورقم الهاتف
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
CREATE POLICY "Users can insert own profile" 
  ON users FOR INSERT 
  WITH CHECK (auth.uid() = uid);
