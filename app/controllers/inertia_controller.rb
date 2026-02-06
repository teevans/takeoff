# frozen_string_literal: true

class InertiaController < ActionController::Base
  # Share data with all Inertia responses
  # see https://inertia-rails.dev/guide/shared-data
  inertia_share auth: -> {
    if Current.user
      {
        user: {
          id: Current.user.id,
          name: Current.user.name,
          email: Current.user.email_address,
          companies: Current.user.company_users.includes(:company).map do |cu|
            {
              id: cu.company.id,
              name: cu.company.name,
              role: cu.role
            }
          end,
          current_company_id: Current.company&.id
        }
      }
    end
  }
end
