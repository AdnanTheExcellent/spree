require 'spec_helper'

describe 'Order Risk Analysis' do
  stub_authorization!

  let!(:order) do
    create(:completed_order_with_pending_payment)
  end

  def visit_order
    visit spree.admin_path
    click_link 'Orders'
    within_row(1) do
      click_link order.number
    end
  end

  context "the order is considered risky" do
    
    before do
      order.payments.first.update_column(:avs_response, 'X')
      order.considered_risky!
      visit_order
    end

    it "displays 'Risk Analysis' box" do
      expect(page).to have_content 'Risk Analysis'
    end

    it "can be approved" do
      click_button('approve')
      expect(page).to have_content 'Approver'
      expect(page).to have_content 'Approved at'
      expect(page).to have_content 'Status: complete'
    end

    it "can be canceled and resumed" do
      click_button('cancel')
      expect(page).to have_content 'Status: canceled'
      click_button('resume')
      expect(page).to have_content 'Status: considered risky'
    end
  end
  
  context "the order is not considered risky" do

    before do
      visit_order      
    end

    it "does not display 'Risk Analysis' box" do
      expect(page).to_not have_content 'Risk Analysis'
    end

  end

end