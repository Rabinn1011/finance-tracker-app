-- Recovered from Supabase cluster backup db_cluster-27-01-2026@15-58-41
-- Project udscyznzamtazxzixdap (paused, unrestorable). Schema only; no row data.
-- Replay onto a fresh Supabase project via SQL Editor.

SET default_transaction_read_only = off;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- FUNCTION: create_default_categories_for_user()
CREATE FUNCTION public.create_default_categories_for_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert default expense categories
    INSERT INTO categories (user_id, name, icon, color, type, is_default) VALUES
        (NEW.id, 'Food & Dining', 'food', '#FF6B6B', 'expense', TRUE),
        (NEW.id, 'Shopping', 'shopping', '#9B59B6', 'expense', TRUE),
        (NEW.id, 'Travel', 'travel', '#5B9BD5', 'expense', TRUE),
        (NEW.id, 'Bills', 'bills', '#FFA726', 'expense', TRUE),
        (NEW.id, 'Entertainment', 'entertainment', '#E91E63', 'expense', TRUE),
        (NEW.id, 'Healthcare', 'healthcare', '#4CAF50', 'expense', TRUE),
        (NEW.id, 'Education', 'education', '#2196F3', 'expense', TRUE),
        (NEW.id, 'Other', 'other', '#9E9E9E', 'expense', TRUE);
    
    -- Insert default income categories
    INSERT INTO categories (user_id, name, icon, color, type, is_default) VALUES
        (NEW.id, 'Salary', 'salary', '#4CAF50', 'income', TRUE),
        (NEW.id, 'Freelance', 'freelance', '#2196F3', 'income', TRUE),
        (NEW.id, 'Investment', 'investment', '#9C27B0', 'income', TRUE),
        (NEW.id, 'Other Income', 'other', '#607D8B', 'income', TRUE);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.create_default_categories_for_user() OWNER TO postgres;

-- FUNCTION: create_default_payment_methods_for_user()
CREATE FUNCTION public.create_default_payment_methods_for_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert default payment methods
    INSERT INTO payment_methods (user_id, name, type, icon, balance) VALUES
        (NEW.id, 'Cash', 'cash', 'cash', 0.00),
        (NEW.id, 'eSewa', 'ewallet', 'esewa', 0.00),
        (NEW.id, 'Khalti', 'ewallet', 'khalti', 0.00);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.create_default_payment_methods_for_user() OWNER TO postgres;

-- FUNCTION: update_payment_method_balance()
CREATE FUNCTION public.update_payment_method_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Handle INSERT
    IF TG_OP = 'INSERT' THEN
        IF NEW.type = 'income' THEN
            UPDATE payment_methods
            SET balance = balance + NEW.amount
            WHERE id = NEW.payment_method_id;
        ELSIF NEW.type = 'expense' THEN
            UPDATE payment_methods
            SET balance = balance - NEW.amount
            WHERE id = NEW.payment_method_id;
        END IF;
        RETURN NEW;
    END IF;

    -- Handle UPDATE
    IF TG_OP = 'UPDATE' THEN
        -- Reverse the old transaction
        IF OLD.type = 'income' THEN
            UPDATE payment_methods
            SET balance = balance - OLD.amount
            WHERE id = OLD.payment_method_id;
        ELSIF OLD.type = 'expense' THEN
            UPDATE payment_methods
            SET balance = balance + OLD.amount
            WHERE id = OLD.payment_method_id;
        END IF;

        -- Apply the new transaction
        IF NEW.type = 'income' THEN
            UPDATE payment_methods
            SET balance = balance + NEW.amount
            WHERE id = NEW.payment_method_id;
        ELSIF NEW.type = 'expense' THEN
            UPDATE payment_methods
            SET balance = balance - NEW.amount
            WHERE id = NEW.payment_method_id;
        END IF;
        RETURN NEW;
    END IF;

    -- Handle DELETE
    IF TG_OP = 'DELETE' THEN
        IF OLD.type = 'income' THEN
            UPDATE payment_methods
            SET balance = balance - OLD.amount
            WHERE id = OLD.payment_method_id;
        ELSIF OLD.type = 'expense' THEN
            UPDATE payment_methods
            SET balance = balance + OLD.amount
            WHERE id = OLD.payment_method_id;
        END IF;
        RETURN OLD;
    END IF;
END;
$$;


ALTER FUNCTION public.update_payment_method_balance() OWNER TO postgres;

-- FUNCTION: update_updated_at_column()
CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

-- TABLE: budgets
CREATE TABLE public.budgets (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    category_id uuid,
    amount numeric(15,2) NOT NULL,
    period text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT budgets_period_check CHECK ((period = ANY (ARRAY['weekly'::text, 'monthly'::text, 'yearly'::text])))
);


ALTER TABLE public.budgets OWNER TO postgres;

-- TABLE: categories
CREATE TABLE public.categories (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    name text NOT NULL,
    icon text NOT NULL,
    color text NOT NULL,
    type text NOT NULL,
    is_default boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT categories_type_check CHECK ((type = ANY (ARRAY['expense'::text, 'income'::text])))
);


ALTER TABLE public.categories OWNER TO postgres;

-- TABLE: payment_methods
CREATE TABLE public.payment_methods (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    name text NOT NULL,
    type text NOT NULL,
    icon text NOT NULL,
    balance numeric(15,2) DEFAULT 0.00,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payment_methods_type_check CHECK ((type = ANY (ARRAY['ewallet'::text, 'bank'::text, 'cash'::text])))
);


ALTER TABLE public.payment_methods OWNER TO postgres;

-- TABLE: profiles
CREATE TABLE public.profiles (
    id uuid NOT NULL,
    full_name text NOT NULL,
    avatar_url text,
    currency text DEFAULT 'NPR'::text,
    currency_symbol text DEFAULT 'Rs.'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.profiles OWNER TO postgres;

-- TABLE: transactions
CREATE TABLE public.transactions (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    payment_method_id uuid,
    category_id uuid,
    amount numeric(15,2) NOT NULL,
    type text NOT NULL,
    description text,
    notes text,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT transactions_type_check CHECK ((type = ANY (ARRAY['expense'::text, 'income'::text])))
);


ALTER TABLE public.transactions OWNER TO postgres;

-- CONSTRAINT: budgets budgets_pkey
ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);

-- CONSTRAINT: categories categories_pkey
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);

-- CONSTRAINT: payment_methods payment_methods_pkey
ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);

-- CONSTRAINT: profiles profiles_pkey
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);

-- CONSTRAINT: transactions transactions_pkey
ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);

-- INDEX: idx_transactions_category
CREATE INDEX idx_transactions_category ON public.transactions USING btree (category_id);

-- INDEX: idx_transactions_payment_method
CREATE INDEX idx_transactions_payment_method ON public.transactions USING btree (payment_method_id);

-- INDEX: idx_transactions_user_date
CREATE INDEX idx_transactions_user_date ON public.transactions USING btree (user_id, transaction_date DESC);

-- INDEX: idx_transactions_user_type
CREATE INDEX idx_transactions_user_type ON public.transactions USING btree (user_id, type);

-- TRIGGER: profiles trigger_create_default_categories
CREATE TRIGGER trigger_create_default_categories AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.create_default_categories_for_user();

-- TRIGGER: profiles trigger_create_default_payment_methods
CREATE TRIGGER trigger_create_default_payment_methods AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.create_default_payment_methods_for_user();

-- TRIGGER: transactions trigger_update_payment_method_balance
CREATE TRIGGER trigger_update_payment_method_balance AFTER INSERT OR DELETE OR UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.update_payment_method_balance();

-- TRIGGER: budgets update_budgets_updated_at
CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON public.budgets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- TRIGGER: payment_methods update_payment_methods_updated_at
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON public.payment_methods FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- TRIGGER: profiles update_profiles_updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- TRIGGER: transactions update_transactions_updated_at
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- FK CONSTRAINT: budgets budgets_category_id_fkey
ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;

-- FK CONSTRAINT: budgets budgets_user_id_fkey
ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- FK CONSTRAINT: categories categories_user_id_fkey
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- FK CONSTRAINT: payment_methods payment_methods_user_id_fkey
ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- FK CONSTRAINT: profiles profiles_id_fkey
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- FK CONSTRAINT: transactions transactions_category_id_fkey
ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;

-- FK CONSTRAINT: transactions transactions_payment_method_id_fkey
ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id) ON DELETE SET NULL;

-- FK CONSTRAINT: transactions transactions_user_id_fkey
ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- POLICY: budgets Users can create their own budgets
CREATE POLICY "Users can create their own budgets" ON public.budgets FOR INSERT WITH CHECK ((auth.uid() = user_id));

-- POLICY: categories Users can create their own categories
CREATE POLICY "Users can create their own categories" ON public.categories FOR INSERT WITH CHECK ((auth.uid() = user_id));

-- POLICY: payment_methods Users can create their own payment methods
CREATE POLICY "Users can create their own payment methods" ON public.payment_methods FOR INSERT WITH CHECK ((auth.uid() = user_id));

-- POLICY: transactions Users can create their own transactions
CREATE POLICY "Users can create their own transactions" ON public.transactions FOR INSERT WITH CHECK ((auth.uid() = user_id));

-- POLICY: budgets Users can delete their own budgets
CREATE POLICY "Users can delete their own budgets" ON public.budgets FOR DELETE USING ((auth.uid() = user_id));

-- POLICY: categories Users can delete their own categories
CREATE POLICY "Users can delete their own categories" ON public.categories FOR DELETE USING (((auth.uid() = user_id) AND (is_default = false)));

-- POLICY: payment_methods Users can delete their own payment methods
CREATE POLICY "Users can delete their own payment methods" ON public.payment_methods FOR DELETE USING ((auth.uid() = user_id));

-- POLICY: transactions Users can delete their own transactions
CREATE POLICY "Users can delete their own transactions" ON public.transactions FOR DELETE USING ((auth.uid() = user_id));

-- POLICY: profiles Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK ((auth.uid() = id));

-- POLICY: budgets Users can update their own budgets
CREATE POLICY "Users can update their own budgets" ON public.budgets FOR UPDATE USING ((auth.uid() = user_id));

-- POLICY: categories Users can update their own categories
CREATE POLICY "Users can update their own categories" ON public.categories FOR UPDATE USING ((auth.uid() = user_id));

-- POLICY: payment_methods Users can update their own payment methods
CREATE POLICY "Users can update their own payment methods" ON public.payment_methods FOR UPDATE USING ((auth.uid() = user_id));

-- POLICY: profiles Users can update their own profile
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING ((auth.uid() = id));

-- POLICY: transactions Users can update their own transactions
CREATE POLICY "Users can update their own transactions" ON public.transactions FOR UPDATE USING ((auth.uid() = user_id));

-- POLICY: budgets Users can view their own budgets
CREATE POLICY "Users can view their own budgets" ON public.budgets FOR SELECT USING ((auth.uid() = user_id));

-- POLICY: categories Users can view their own categories
CREATE POLICY "Users can view their own categories" ON public.categories FOR SELECT USING ((auth.uid() = user_id));

-- POLICY: payment_methods Users can view their own payment methods
CREATE POLICY "Users can view their own payment methods" ON public.payment_methods FOR SELECT USING ((auth.uid() = user_id));

-- POLICY: profiles Users can view their own profile
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING ((auth.uid() = id));

-- POLICY: transactions Users can view their own transactions
CREATE POLICY "Users can view their own transactions" ON public.transactions FOR SELECT TO authenticated USING ((auth.uid() = user_id));

-- ROW SECURITY: budgets
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

-- ROW SECURITY: categories
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- ROW SECURITY: payment_methods
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

-- ROW SECURITY: profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ROW SECURITY: transactions
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- ACL: FUNCTION create_default_categories_for_user()
GRANT ALL ON FUNCTION public.create_default_categories_for_user() TO anon;
GRANT ALL ON FUNCTION public.create_default_categories_for_user() TO authenticated;
GRANT ALL ON FUNCTION public.create_default_categories_for_user() TO service_role;

-- ACL: FUNCTION create_default_payment_methods_for_user()
GRANT ALL ON FUNCTION public.create_default_payment_methods_for_user() TO anon;
GRANT ALL ON FUNCTION public.create_default_payment_methods_for_user() TO authenticated;
GRANT ALL ON FUNCTION public.create_default_payment_methods_for_user() TO service_role;

-- ACL: FUNCTION update_payment_method_balance()
GRANT ALL ON FUNCTION public.update_payment_method_balance() TO anon;
GRANT ALL ON FUNCTION public.update_payment_method_balance() TO authenticated;
GRANT ALL ON FUNCTION public.update_payment_method_balance() TO service_role;

-- ACL: FUNCTION update_updated_at_column()
GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;

-- ACL: TABLE budgets
GRANT ALL ON TABLE public.budgets TO anon;
GRANT ALL ON TABLE public.budgets TO authenticated;
GRANT ALL ON TABLE public.budgets TO service_role;

-- ACL: TABLE categories
GRANT ALL ON TABLE public.categories TO anon;
GRANT ALL ON TABLE public.categories TO authenticated;
GRANT ALL ON TABLE public.categories TO service_role;

-- ACL: TABLE payment_methods
GRANT ALL ON TABLE public.payment_methods TO anon;
GRANT ALL ON TABLE public.payment_methods TO authenticated;
GRANT ALL ON TABLE public.payment_methods TO service_role;

-- ACL: TABLE profiles
GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;

-- ACL: TABLE transactions
GRANT ALL ON TABLE public.transactions TO anon;
GRANT ALL ON TABLE public.transactions TO authenticated;
GRANT ALL ON TABLE public.transactions TO service_role;

