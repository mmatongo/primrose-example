require 'sinatra'
require 'primrose'

# Create a new store
store = Primrose::Store.new({todos: [{text: "Task 1", completed: false}, {text: "Task 2", completed: false}]})

helpers do
  include Primrose::Helpers
end

before do
  # Make the store available to routes
  @store = store
end

get '/' do
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
  new_todo = { text: params[:new_todo], completed: false }
  puts "Adding new todo: #{new_todo}"
  @store.dispatch(
    type: 'ADD_TODO',
    updates: {
      todos: ->(todos) { todos + [new_todo] }
    }
  )
  redirect '/'
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
