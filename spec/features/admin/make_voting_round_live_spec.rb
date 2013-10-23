require 'features/features_spec_helper'

describe "Make voting round live" do
  it "has no voting round on main page before making voting round live" do
    voting_round = FactoryGirl.create(:voting_round)
    @home_page = Home.new
    @home_page.load
    expect(@home_page.has_voting_round?).to be_false
  end

  it "shows the active voting round on the home page" do
    voting_round = FactoryGirl.create(:voting_round)
    @edit_voting_round_page = Admin::EditVotingRound.new
    @edit_voting_round_page.load(id: voting_round.id)
    @edit_voting_round_page.status_dropdown.select("Live")
    @edit_voting_round_page.update_button.click
    @home_page = Home.new
    @home_page.load
    expect(@home_page.has_voting_round?).to be_true
  end
end
