require 'spec_helper'

describe Admin do
  
  before do
    @admin = Admin.create(username: "user", password: "password", password_confirmation: "password")
  end

  subject{ @admin }

  context "username" do
    it { should respond_to(:username) }
  end

  context "password" do
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:password_digest) }
    it { should respond_to(:remember_token) }
    it { should respond_to(:authenticate) }

    describe "return value of authenticate method" do
      before { @admin.save }
      let(:found_admin) { Admin.find_by(username: @admin.username) }

      describe "with valid password" do
        it { should eq found_admin.authenticate(@admin.password) }
      end

      describe "with invalid password" do
        let(:admin_for_invalid_password) { found_admin.authenticate("invalid") }
      end
    end
  end
end