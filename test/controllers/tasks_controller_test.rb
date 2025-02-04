require "test_helper"

describe TasksController do
  let (:task) {
    Task.create name: "sample task", description: "this is an example for a test",
    completed: Time.now + 5.days
  }
  
  # Tests for Wave 1
  describe "index" do
    it "can get the index path" do
      # Act
      get "/tasks"
      
      # Assert
      must_respond_with :success
    end
    
    it "can get the root path" do
      # Act
      get "/"
      
      # Assert
      must_respond_with :success
    end
  end
  
  describe "show" do
    it "can get a valid task" do
      # Act
      get task_path(task.id)
      
      # Assert
      must_respond_with :success
    end
    
    it "will redirect for an invalid task" do
      # Act
      get task_path(-1)
      
      # Assert
      must_respond_with :redirect
    end
  end
  
  describe "new" do
    it "can get the new task page" do
      
      # Act
      get new_task_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  describe "create" do
    it "can create a new task" do
      
      # Arrange
      task_hash = {
        task: {
          name: "new task",
          description: "new task description",
          completed: nil,
        },
      }
      
      # Act-Assert
      expect {
        post tasks_path, params: task_hash
      }.must_change "Task.count", 1
      
      new_task = Task.find_by(name: task_hash[:task][:name])
      expect(new_task.description).must_equal task_hash[:task][:description]
      expect(new_task.completed).must_equal task_hash[:task][:completed]
      
      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
  end
  
  describe "edit" do
    it "can get the edit page for an existing task" do
      get task_path(task.id)
      
      # Assert
      must_respond_with :success
    end
    
    it "will respond with redirect when attempting to edit a nonexistant task" do
      patch task_path(-1)
      
      # Assert
      must_respond_with :redirect 
    end
  end
  
  describe "update" do
    before do
      @new_task = Task.create(name: "new task")
    end
    
    it "can update an existing task" do
      existing_task = Task.first
      updated_task_form_data = {
        task: {
          name: "Melt chocolate",
          description: "Whisk chocolate shavings into saucepan on low heat until melted",
          completed: 10-06-2019
        }
      }
      expect {
        patch task_path(existing_task.id), params: updated_task_form_data
      }.wont_change 'Task.count'
      
      expect( Task.find_by(id: existing_task.id).name ).must_equal "Melt chocolate"
    end
  end
  
  it "will redirect to the root page if invalid id is given" do
    invalid_id = -1
    updated_task_form_data = {
      task: {
        name: "Melt chocolate",
        description: "Whisk chocolate shavings into saucepan on low heat until melted",
        completed: 10-06-2019
      }
    }
    patch task_path(invalid_id), params: updated_task_form_data
    
    # Assert
    must_respond_with :redirect
    must_redirect_to root_path
  end
  
  describe "destroy" do
    it "deletes a task if given a valid id" do
      valid_task = Task.first
      
      expect {
        delete task_path(valid_task)
      }.must_change 'Task.count', 1
      
      # Assert
      must_respond_with :redirect
      must_redirect_to root_path
    end
    
    it "will return not found if invalid id is given to delete" do
      invalid_id = -1
      # Act
      delete task_path(invalid_id)
      
      # Assert
      must_respond_with :not_found
      
    end
  end
  
  describe "toggle_complete" do
    before do
      @completed_task = Task.create(name: "completed task", completed: Time.now)
      @incompleted_task = Task.create(name: "incomplete task")
    end
    it "will respond with not found if invalid id is given" do
      invalid_id = -1
      # Act
      get task_status_path(invalid_id)
      
      # Assert
      must_respond_with :not_found
    end
    
    it "if completed is nil assign timestamp" do
      task = @incompleted_task 
      
      # Act
      get task_status_path(task)
      
      # Assert
      must_respond_with :redirect
      must_redirect_to tasks_path
      expect( Task.find_by(id: task.id).completed ).wont_be_nil 
    end 
    
    it "if completed has a timestamp, assign nil" do
      completed_task = @completed_task
      
      # Act
      get task_status_path(completed_task)
      
      # Assert
      must_respond_with :redirect
      must_redirect_to tasks_path
      expect( Task.find_by(id: completed_task.id).completed ).must_be_nil
    end
  end
end

