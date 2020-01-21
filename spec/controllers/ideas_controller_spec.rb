require 'rails_helper'

RSpec.describe IdeasController, type: :controller do
    def current_user
        @current_user ||= FactoryBot.create(:user)
      end
    
      def unauthorized_user
        @other_user ||= FactoryBot.create(:user)
      end
    
      describe '#new' do
        context 'with no user signed in' do 
            it 'should redirect to session#new' do
                get(:new) 
                expect(response).to redirect_to(new_session_path)
            end 
            it 'sets a flash danger message' do 
                get(:new)
                expect(flash[:danger]).to be
            end
        end
        context 'with user signed in' do
            before do 
                session[:user_id] = current_user.id
            end
            it 'should get the new template' do
                get(:new)
                expect(response).to(render_template(:new)) 
            end
    
            it 'should set an instance variable with a new idea post' do
                get(:new)
                expect(assigns(:idea)).to(be_a_new(Idea))
            end
        end
    end
    
      describe '#create' do
        
        def valid_request 
            post(:create, params: { idea: FactoryBot.attributes_for(:idea)})
        end
        context 'with no user signed in' do 
            it 'should redirect to session#new' do
                valid_request 
                expect(response).to redirect_to(new_session_path)
            end 
            it 'sets a flash danger message' do 
                valid_request
                expect(flash[:danger]).to be
            end
        end
        context 'with user signed in' do
            before do
                session[:user_id] = current_user.id
            end
            context 'with valid parameters' do
    
                it 'should create a new idea in the db' do
                    count_before = Idea.count
                    valid_request
                    count_after = Idea.count 
                    expect(count_after).to eq(count_before + 1)
                end
                it 'should redirect to the show page of that post' do
                    valid_request
                    idea = Idea.last
                    expect(response).to(redirect_to(idea_path(idea)))
                end
                it 'associates the current_user to the created Idea' do
                    valid_request
                    idea = Idea.last
                    expect(idea.user).to eq(current_user)
                end
            end
    
            context 'with invalid parameters' do
                def invalid_request 
                    post(:create, params: { idea: FactoryBot.attributes_for(:idea, title: nil)})
                end
                it 'should assign an invalid idea as an instance variable' do 
                    invalid_request
                    expect(assigns(:idea)).to be_a(Idea)
                    expect(assigns(:idea).valid?).to be(false)
                end
                it 'should get the new template' do 
                    invalid_request
                    expect(response).to(render_template(:new)) 
                end
                it 'should not create a idea in the db' do 
                    count_before = Idea.count
                    invalid_request
                    count_after = Idea.count 
                    expect(count_after).to eq(count_before)
                end
            end
        end
    end
    
    describe '#show' do 
        it 'get the show template' do 
            idea = FactoryBot.create(:idea)
            get(:show, params: {id: idea.id})
            expect(response).to render_template(:show)
        end
        it 'should set an instance variable idea for the shown object' do 
            idea = FactoryBot.create(:idea)
            get(:show, params: {id: idea.id})
            expect(assigns(:idea)).to eq(idea)
        end
    end
    
    describe '#destroy' do
         context 'with no user signed in' do 
            before do 
                idea = FactoryBot.create(:idea)
                delete(:destroy, params: {id: idea.id})
            end
            it 'should redirect to session#new' do
                expect(response).to redirect_to(new_session_path)
            end 
            it 'sets a flash danger message' do 
                expect(flash[:danger]).to be
            end
        end
        context 'with signed in user' do 
            before do 
                session[:user_id] = current_user.id
            end
            context 'as non-owner' do 
                it 'redirects to idea show' do 
                    idea = FactoryBot.create(:idea)
                    delete(:destroy, params: {id: idea.id})
                    expect(response).to redirect_to idea_path(idea)
                end
                it 'sets a flash danger' do
                    idea = FactoryBot.create(:idea)
                    delete(:destroy, params: {id: idea.id})
                    expect(flash[:danger]).to be
                end
                it 'does not remove a Idea' do
                    idea = FactoryBot.create(:idea)
                    delete(:destroy, params: {id: idea.id})
                    expect(Idea.find_by(id: idea.id)).to eq(idea)
                end  
            end
            context 'as owner' do 
                it 'removes a Idea from the database' do 
                    idea = FactoryBot.create(:idea, user: current_user)
                    delete(:destroy, params: {id: idea.id})
                    expect(Idea.find_by(id: idea.id)).to be(nil)
                end
                it 'redirects to the idea index' do
                    idea = FactoryBot.create(:idea, user: current_user)
                    delete(:destroy, params: {id: idea.id})
                    expect(response).to(redirect_to root_path )
                end 
            end
        end
    end
    
    describe "#edit" do
    
        context "with no user signed in" do
            it "redirects to the sign in page" do
                idea = FactoryBot.create(:idea, user: current_user)
                get :edit, params: { id: idea.id }
                expect(response).to redirect_to new_session_path
            end
        end
    
        context "with user signed in" do
            context "with authorized user" do
                before do
                    session[:user_id] = current_user.id
                    @idea = FactoryBot.create(:idea, user: current_user)
                    get :edit, params: { id: @idea.id }
                end
    
                it "gets the edit template" do
                    expect(response).to render_template :edit
                end
    
                it "sets an instance variable based on the idea id that is passed" do
                    expect(assigns(:idea)).to eq(@idea)
                end
            end
    
            context "with unauthorized user" do
                before do
                    session[:user_id] = unauthorized_user.id
                end
                
                it "redirects to the idea show path" do
                    idea = FactoryBot.create(:idea, user: current_user)
                    get :edit, params: { id: idea.id }
                    expect(response).to redirect_to idea_path(idea)
                end
    
            end
        end
    end
    
    describe "#update" do
    
        context "with user signed in" do
            context "with authorized user" do
                before do
                session[:user_id] = current_user.id
                end
                context 'with valid parameters' do
    
                    it "updates the idea record with new attributes" do
                        idea = FactoryBot.create(:idea, user: current_user)
                        new_title = "#{idea.title} Plus Changes!"
                        patch :update, params: {id: idea.id, idea: {title: new_title}}
                        expect(idea.reload.title).to eq(new_title)
                    end
    
                    it "redirect to the idea show page" do
                        idea = FactoryBot.create(:idea, user: current_user)
                        new_title = "#{idea.title} plus changes!"
                        patch :update, params: {id: idea.id, idea: {title: new_title}}
                        expect(response).to redirect_to(idea)
                    end
                end
    
                context 'with invalid parameters' do
                    def invalid_request
                        patch :update, params: {id: @idea.id, idea: {title: nil}}
                    end
    
                    it "doesn't update the idea with new attributes" do
                        @idea = FactoryBot.create(:idea, user: current_user)
                        expect { invalid_request }.not_to change { @idea.reload.title }
                    end
    
                    it "gets the edit template" do
                        @idea = FactoryBot.create(:idea, user: current_user)
                        invalid_request
                        expect(response).to render_template(:edit)
                    end
                end
            end
    
            context "with unauthorized user" do
                before do
                    session[:user_id] = unauthorized_user.id
                end
                
                it "redirects to the idea path" do
                    idea = FactoryBot.create(:idea, user: current_user)
                    patch :update, params: {id: idea.id, idea: {title: "New title that shouldn't be updated anyways"}}
                    expect(response).to redirect_to idea_path(idea)
                end
            end
        end
    end
    
    describe '#index' do
    
        before do
            get :index
        end
    
        it "gets the index template" do
            expect(response).to render_template(:index)
        end
    
        it "assigns an instance variable to all created news articles (sorted by created_at)" do
            idea_1 = FactoryBot.create(:idea)
            idea_2 = FactoryBot.create(:idea)
            expect(assigns(:ideas)).to eq([idea_2, idea_1])
        end
    end
end
