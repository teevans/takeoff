# Takeoff Project Notes

## Fizzy Model Architecture Patterns

### Core Principles
- **Lean Controllers**: Controllers only handle request/response, delegating business logic to models
- **Rich Models with Concerns**: Extract reusable logic into concerns when it makes sense
- **No Services**: Business logic lives in models, not service objects
- **Fixtures over Factories**: Use fixtures for test data, not FactoryBot

### Model Design Patterns

#### Using Concerns for Extracted Logic
When models grow complex, extract related functionality into concerns:

```ruby
# app/models/concerns/tokenizable.rb
module Tokenizable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
    scope :active, -> { where("expires_at > ?", Time.current) }
  end

  def expired?
    expires_at < Time.current
  end

  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at = 15.minutes.from_now
  end
end

# app/models/authentication_token.rb
class AuthenticationToken < ApplicationRecord
  include Tokenizable
  # Model-specific logic here
end
```

#### Rich Models with Business Logic
Keep business logic in models, not controllers or services:

```ruby
class User < ApplicationRecord
  # Associations and validations
  has_many :sessions, dependent: :destroy
  
  # Business logic methods
  def send_welcome_email
    token = authentication_tokens.create!
    AuthenticationMailer.with(user: self, token: token).welcome.deliver_later
  end
  
  # State management
  def activate!
    update!(activated_at: Time.current)
  end
end
```

### Lean Controller Pattern

Controllers should be minimal and focused:

```ruby
class SignupsController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      @user.send_welcome_email  # Business logic in model
      redirect_to verify_path
    else
      redirect_to new_signup_path, inertia: { errors: @user.errors }
    end
  end
  
  private
  
  def user_params
    params.permit(:email_address, :name)
  end
end
```

### Testing with Fixtures

#### Fixture Setup
```yaml
# test/fixtures/users.yml
john:
  name: John Doe
  email_address: john@example.com
  
jane:
  name: Jane Smith
  email_address: jane@example.com
```

#### Test Pattern
```ruby
class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:john)  # Use fixtures
  end
  
  test "user validation" do
    assert @user.valid?
  end
end
```

### Authentication Pattern
- Passwordless authentication using magic links
- Session management through Current attributes
- Token-based verification with expiration

## Form Validation with Inertia.js

When handling form validation errors in Inertia.js forms:

- **USE** the `errors` prop from the Form component's render function
- **DO NOT** use `usePage` hook to access errors
- The Form component provides `errors` directly in its render prop function
- In the Rails controller, render with `status: :unprocessable_entity` for validation errors
- Inertia Rails automatically shares model errors when configured with `config.always_include_errors_hash = true`

### Frontend Example:

```tsx
// CORRECT - Use errors from Form render prop
<Form action="/signups" method="post">
    {({processing, errors}) => (
        // Use errors here
        {errors.email_address && (
            <FieldError>{errors.email_address}</FieldError>
        )}
    )}
</Form>

// INCORRECT - Don't use usePage for form errors
const { props: pageProps } = usePage();
const errors = pageProps?.errors || {};
```

### Backend Example:

```ruby
def create
  @user = User.new(user_params)
  
  if @user.save
    redirect_to some_path
  else
    # Use redirect_to with inertia errors option
    redirect_to new_signup_path, inertia: { errors: @user.errors }
  end
end
```

**Important:** Always use `redirect_to` with `inertia: { errors: ... }` for validation errors, NOT `render`. This ensures errors are properly shared with the frontend Form component.

## shadcn/ui Field Components

- Use `Field` component with `data-invalid` prop to mark invalid fields
- Use `Input` component with `aria-invalid` prop for accessibility
- Use `FieldError` component to display validation messages
- The Input component automatically shows error styling when `aria-invalid={true}`