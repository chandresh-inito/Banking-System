Rails.application.routes.draw do
  # mount_devise_token_auth_for 'User', at: 'auth'
  root 'home#index'
  devise_for :users

  resources :home, only: [:index]
  get 'user_details' , to: "home#user_details"
  
  resources :admin
  get 'user_transactions', to: "admin#user_transactions"
  get 'search' , to: "admin#search"

  resources :account

  # resources :account do
  #   collection do
  #     get 'credit_form'
  #   end
  # end

  #credit
  get 'credit_form' , to: "account#credit_form"
  post 'credit', to: "account#credit"

  #withdraw
  get 'withdrawal_page', to: "account#withdrawal_page"
  get 'current_account_withdrawal_form' , to: "account#current_account_withdrawal_form"
  post 'current_account_withdrawal' , to: "account#current_account_withdrawal"
  get 'saving_account_withdrawal_page' , to: "account#saving_account_withdrawal_page"
  get 'saving_account_withdrawal_atm_form' , to: "account#saving_account_withdrawal_atm_form"
  post 'saving_account_withdrawal_atm' , to: "account#saving_account_withdrawal_atm"
  get 'saving_account_withdrawal_direct_form' , to: "account#saving_account_withdrawal_direct_form"
  post 'saving_account_withdrawal_direct' , to: "account#saving_account_withdrawal_direct"

  #loan
  get 'new_loan_account' , to: "account#new_loan_account"
  post 'create_loan_account', to: "account#create_loan_account"
  get 'new_loan_deposit' , to: "account#new_loan_deposit"
  post 'create_loan_deposit' , to: "account#create_loan_deposit"
  get 'loan_details' , to: "account#loan_details"
  

  namespace :api do

    mount_devise_token_auth_for 'User', at: 'auth', controllers:{
      sessions: 'api/sessions'
    }

    defaults format: :json do
      resources :account
      post 'deposit' , to: "account#deposit"

      resources :loan
      post 'loan_deposit' , to: "loan#loan_deposit"
      post 'create_loan_account' , to: "loan#create_loan_account"
      post 'loan_details' , to: "loan#loan_details"
      

      resources :withdraw
      post 'atm_withdraw' , to: "withdraw#atm_withdraw"
      post 'direct_withdraw' , to: "withdraw#direct_withdraw"
      
      resources :transaction
    end

    # default format: :json do
     
    # end

    # default format: :json do
     
    # end

    # default format: :json do
      
    # end

  
  end
  
end
