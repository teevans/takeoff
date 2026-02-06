# Controller Patterns and Best Practices

## Core Philosophy
Controllers should be **clear and readable** without unnecessary abstractions. Every method should have a descriptive name that makes its purpose obvious, but avoid over-engineering with too many tiny methods.

## The Gold Standard Pattern

```ruby
class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:edit, :update, :destroy]

  def create
    @company = Company.create_with_owner(
      name: company_params[:name],
      owner: Current.user
    )

    Current.company = @company
    redirect_to @company, notice: "Company created successfully"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_company_path, inertia: { errors: e.record.errors }
  end

  private

  # ============================================================================
  # Before Action Methods
  # ============================================================================

  def set_company
    @company = Current.user.companies.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: "Company not found"
  end

  def require_admin
    return if Current.user.administrator_of?(@company)
    redirect_to @company, alert: "Only administrators can perform this action"
  end
end
```

## Key Principles

### 1. Keep Actions Readable
Actions should be easy to follow without jumping through too many methods:

```ruby
def create
  @user = User.new(signup_params)
  
  if @user.save
    session[:pending_email] = @user.email_address
    
    token = @user.authentication_tokens.create!
    send_welcome_email(token)
    store_development_credentials(token) if Rails.env.development?
    
    redirect_to verify_session_path, notice: "Check your email to confirm your account"
  else
    redirect_to new_signups_path, inertia: { errors: @user.errors }
  end
end
```

### 2. Extract Complex Logic, Keep Simple Logic Inline
- **Extract** when logic is complex or reusable
- **Keep inline** when it's straightforward and only used once

```ruby
# Good - Complex logic extracted
def find_authentication_token
  if params[:token].present?
    AuthenticationToken.find_by_valid_token(params[:token])
  elsif params[:code].present? && email_from_params_or_session
    user = User.find_by(email_address: email_from_params_or_session)
    AuthenticationToken.find_by_valid_code(params[:code], user.id) if user
  end
end

# Good - Simple logic inline
def create
  @company = Company.create_with_owner(
    name: company_params[:name],
    owner: Current.user
  )
  Current.company = @company
  redirect_to @company, notice: "Company created successfully"
end
```

### 3. Group Related Methods with Clear Comments

```ruby
private

# ============================================================================
# Authentication Methods
# ============================================================================

def find_authentication_token
  # ...
end

def redirect_after_authentication(user)
  # ...
end

# ============================================================================
# Magic Link Methods
# ============================================================================

def send_magic_link_email(token)
  # ...
end
```

### 4. Use Descriptive Method Names
Methods should clearly express what they do, but don't go overboard:

- ✅ `send_welcome_email`
- ✅ `user_is_administrator?`
- ✅ `serialize_company_for_show`
- ❌ `redirect_to_company_with_success` (too verbose, just inline it)
- ❌ `create_company_with_current_user_as_owner` (unless it's complex)

## Common Method Categories

### Before Actions
```ruby
def set_company
  @company = Current.user.companies.find(params[:id])
rescue ActiveRecord::RecordNotFound
  redirect_to companies_path, alert: "Company not found"
end
```

### Authorization
```ruby
def require_admin
  return if Current.user.administrator_of?(@company)
  redirect_to @company, alert: "Only administrators can perform this action"
end
```

### Serialization
```ruby
def serialize_company_for_show
  {
    id: @company.id,
    name: @company.name,
    created_at: @company.created_at,
    is_admin: Current.user.administrator_of?(@company),
    members: serialize_company_members
  }
end
```

### Strong Parameters
```ruby
def company_params
  params.permit(:name)
end
```

## Anti-Patterns to Avoid

### ❌ Over-Abstraction
```ruby
# Bad - Too many tiny methods for simple operations
def create
  build_user_from_params
  if save_user_successfully?
    store_email_for_verification
    create_and_send_token
    redirect_to_success_page
  else
    redirect_with_errors
  end
end

def build_user_from_params
  @user = User.new(signup_params)
end

def save_user_successfully?
  @user.save
end

def store_email_for_verification
  session[:pending_email] = @user.email_address
end
```

### ✅ Right Level of Abstraction
```ruby
# Good - Clear and readable without over-engineering
def create
  @user = User.new(signup_params)
  
  if @user.save
    session[:pending_email] = @user.email_address
    token = @user.authentication_tokens.create!
    send_welcome_email(token)
    redirect_to verify_session_path, notice: "Check your email"
  else
    redirect_to new_signups_path, inertia: { errors: @user.errors }
  end
end

def send_welcome_email(token)
  AuthenticationMailer.with(
    user: @user,
    token: token.token,
    code: token.code
  ).welcome.deliver_later
end
```

## Shared Concerns
Use concerns sparingly for truly shared functionality:

```ruby
module MagicLinkAuthentication
  extend ActiveSupport::Concern

  private

  def development_info_for_verification_form
    return unless Rails.env.development? && session[:dev_magic_code]
    
    {
      code: session.delete(:dev_magic_code),
      url: session.delete(:dev_magic_url)
    }
  end
end
```

## Testing
With this pattern, tests remain straightforward:

```ruby
test "create sends welcome email to new user" do
  assert_difference 'User.count' do
    post signups_path, params: { 
      email_address: "new@example.com",
      name: "New User"
    }
  end
  
  assert_enqueued_emails 1
  assert_redirected_to verify_session_path
end
```

## Summary
The goal is **clarity without cleverness**. Code should be:
- Easy to read and understand
- Not over-engineered
- Well-organized with clear sections
- Descriptive but not verbose

When in doubt, favor readability over DRY principles. A little duplication is better than confusing abstractions.