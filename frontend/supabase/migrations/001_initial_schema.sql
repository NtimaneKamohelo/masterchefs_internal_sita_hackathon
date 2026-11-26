CREATE TABLE public.profiles (
    id UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    full_name TEXT NOT NULL,

    address TEXT,

    created_at TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL
        DEFAULT NOW()
);

ALTER TABLE public.profiles
ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    auth.uid() = id
);

CREATE POLICY "Students can create their own profile"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = id
);

CREATE POLICY "Students can update their own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
    auth.uid() = id
)
WITH CHECK (
    auth.uid() = id
);