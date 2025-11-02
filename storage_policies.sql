-- Políticas de Storage para el bucket 'avatars'
-- Estas políticas permiten que los usuarios suban, actualicen y vean solo sus propios avatares

-- Allow users to upload their own avatar
CREATE POLICY "Users can upload their own avatar" ON storage.objects
FOR INSERT WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to update their own avatar
CREATE POLICY "Users can update their own avatar" ON storage.objects
FOR UPDATE USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to view their own avatar
CREATE POLICY "Users can view their own avatar" ON storage.objects
FOR SELECT USING (auth.uid()::text = (storage.foldername(name))[1]);
