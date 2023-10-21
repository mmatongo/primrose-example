require 'sinatra'
require 'primrose'
require 'securerandom'

enable :sessions

# Create a new store
store = Primrose::Store.new({todos: [{text: "Task 1", completed: false}, {text: "Task 2", completed: false}]})

helpers do
  include Primrose::Helpers
end

before do
  # Make the store available to routes
  @store = store
end

# expose the public folder for static assets
set :public_folder, 'public'

get '/' do
  # Generate a nonce for the form
  session[:nonce] = SecureRandom.hex(32)

  @store.state.follow do |state|
    @todos = state[:todos]
    puts "Current state of todos: #{@todos.inspect}"  # Debugging line
  end
  erb :index
end

get '/about' do
  erb :about
end


post '/add_todo' do
  if params[:nonce] == session[:nonce]
    new_todo = { text: params[:new_todo], completed: false }
    @store.dispatch(
      type: 'ADD_TODO',
      updates: {
        todos: ->(todos) { todos + [new_todo] }
      }
    )
    session[:nonce] = nil
    redirect '/'
  else
    # Invalid request
    status 403
    "Forbidden"
  end
end

post '/toggle_todo/:index' do
  index = params[:index].to_i
  new_state = JSON.parse(request.body.read)["completed"]

  @store.dispatch(
    type: 'TOGGLE_TODO',
    updates: {
      todos: ->(todos) {
        todos[index][:completed] = new_state
        todos
      }
    }
  )

  content_type :json
  { success: true }.to_json
end
