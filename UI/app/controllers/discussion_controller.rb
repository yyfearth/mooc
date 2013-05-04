class DiscussionController < ApplicationController
  def index
	@title = "Welcome to Discussion board"
  end

  def add
	@title = "Create a new discussion"
  end

  def search
	@title = "Search a discussion"
  end
end
