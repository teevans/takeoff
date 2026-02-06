require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  def setup
    @company = companies(:acme)
    @user = users(:one)
  end

  test "should be valid" do
    assert @company.valid?
  end

  test "name should be present" do
    @company.name = ""
    assert_not @company.valid?
  end

  test "create_with_owner creates company and assigns owner as administrator" do
    new_user = users(:two)
    company = Company.create_with_owner(name: "New Company", owner: new_user)

    assert company.persisted?
    assert_equal "New Company", company.name
    assert new_user.administrator_of?(company)
    assert_equal "administrator", company.company_users.find_by(user: new_user).role
  end

  test "add_member adds user with specified role" do
    new_user = User.create!(name: "New User", email_address: "new@example.com")
    @company.add_member(new_user, role: "member")

    assert @company.users.include?(new_user)
    assert_equal "member", @company.company_users.find_by(user: new_user).role
  end

  test "administrators returns only admin users" do
    admins = @company.administrators

    assert admins.include?(users(:one))
    assert_not admins.include?(users(:two))
  end

  test "members returns only member users" do
    members = @company.members

    assert members.include?(users(:two))
    assert_not members.include?(users(:one))
  end
end
