# Takeoff

A modern Rails + Inertia.js starter kit inspired by Laravel Breeze, featuring React, TypeScript, shadcn/ui components, and passwordless authentication via magic links.

## Why Takeoff?

Takeoff provides a solid foundation for building modern Rails applications with:

- **Rails 8** with Inertia.js for seamless SPA-like experiences
- **React + TypeScript** for type-safe frontend development
- **shadcn/ui** for beautiful, accessible UI components
- **Magic link authentication** - no passwords to manage
- **Fizzy model architecture** - lean controllers, rich models with concerns
- **Fixture-based testing** - simple, fast test setup

This starter kit eliminates the boilerplate of setting up authentication, frontend tooling, and architectural patterns, letting you focus on building your application.

## Features

- ✨ Passwordless authentication with magic links
- 🎨 Beautiful UI with shadcn/ui components
- 📝 TypeScript for type safety
- 🚀 Vite for lightning-fast HMR
- 🧪 Comprehensive test suite with fixtures
- 🔒 Secure session management
- 📧 Email verification flow
- 🎯 Lean controller pattern with business logic in models

## Requirements

- Ruby 3.3.0 or higher
- Rails 8.0 or higher
- Node.js 20.0 or higher
- PostgreSQL 14 or higher

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/takeoff.git
cd takeoff
```

2. Install dependencies:
```bash
bundle install
npm install
```

3. Setup the database:
```bash
rails db:create
rails db:migrate
```

4. Start the development servers:
```bash
bin/dev
```

This will start both the Rails server (http://localhost:3000) and Vite dev server for hot module replacement.

### Adding shadcn/ui Components

Takeoff comes pre-configured with shadcn/ui. To add new components:

```bash
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dropdown-menu
```

Components will be added to `app/frontend/components/ui/` and can be imported like:

```tsx
import { Button } from "@/components/ui/button"
```

### Project Structure

```
app/
├── frontend/           # React/TypeScript frontend
│   ├── components/     # Reusable components
│   │   └── ui/        # shadcn/ui components
│   ├── pages/         # Inertia page components
│   ├── lib/           # Utilities and helpers
│   └── entrypoints/   # Vite entry points
├── models/            # Rails models with business logic
├── controllers/       # Lean controllers
└── views/            # Server-side views (minimal with Inertia)

test/
├── fixtures/         # Test data using fixtures
├── models/           # Model tests
└── controllers/      # Controller/integration tests
```

## Architecture Patterns

Takeoff follows the Fizzy model architecture:

### Lean Controllers
Controllers only handle request/response:

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
end
```

### Rich Models
Business logic lives in models:

```ruby
class User < ApplicationRecord
  def send_welcome_email
    token = authentication_tokens.create!
    AuthenticationMailer.with(user: self, token: token).welcome.deliver_later
  end
end
```

### Testing with Fixtures
Simple, fast tests using fixtures instead of factories:

```ruby
class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:john)  # Use fixture
  end
  
  test "user validation" do
    assert @user.valid?
  end
end
```

## Authentication Flow

1. User enters email address
2. System sends magic link with verification code
3. User clicks link or enters code
4. Session is created, user is authenticated
5. Sessions persist across devices with secure cookies

## Development

### Running Tests
```bash
rails test
```

### Linting and Formatting
```bash
npm run lint        # Run ESLint
npm run type-check  # Run TypeScript type checking
```

### Email in Development
Magic link codes and URLs are displayed in the console and stored in session for easy development testing.

## Deployment

### Environment Variables
Set these in production:

- `DATABASE_URL` - PostgreSQL connection string
- `SECRET_KEY_BASE` - Rails secret key
- `RAILS_MASTER_KEY` - Rails credentials key
- Email configuration for your mail provider

### Kamal Deployment
Takeoff includes Kamal configuration for easy deployment:

```bash
kamal setup
kamal deploy
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- Inspired by [Laravel Breeze](https://laravel.com/docs/breeze) React + Inertia starter kit
- UI components from [shadcn/ui](https://ui.shadcn.com)
- Built with [Inertia.js](https://inertiajs.com) for the best of both worlds