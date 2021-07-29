class BooksController < ApplicationController
  def new
    @current_step ||= 1
    
    # empty state initialization
    @book = session.fetch(:new_book, Book.new(author: "John Doe", title: "Lorem Ipsum", pages: 0))
    
    render inline: <<~HTML
      <html>
        <head>
          <title>Book Wizard Demo</title>
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
          <%= javascript_include_tag "/index.js", type: "module" %>
        </head>
        <body>
          <div class="container my-5">
            <h1>Book Wizard</h1>
            
            <h3 class="mt-4">New Book</h3>
            <div data-step="<%= @current_step %>">
              <ul class="nav nav-pills nav-justified">
                <li class="nav-item">
                  <a class="nav-link <%= 'disabled' if @current_step < 1 %> <%= 'active' if @current_step == 1 %>" aria-current="page" href="#">Author</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link <%= 'disabled' if @current_step < 2 %> <%= 'active' if @current_step == 2 %>" href="#">Title</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link <%= 'disabled' if @current_step < 3 %> <%= 'active' if @current_step == 3 %>" href="#">Meta</a>
                </li>
              </ul>
              
              <div class="btn-group mt-4" role="group" aria-label="Basic outlined example">
                <button type="button" class="btn btn-outline-primary" data-reflex="click->BookWizard#refresh" data-incr="-1" data-reflex-form-selector="#new_book" data-reflex-dataset="combined" <%= 'disabled' if @current_step == 1 %>>Previous</button>
                <button type="button" class="btn btn-outline-primary" data-reflex="click->BookWizard#refresh" data-incr="1" data-reflex-form-selector="#new_book" data-reflex-dataset="combined" <%= 'disabled' if @current_step == 3 %>>Next</button>
              </div>
              
              <%= form_for @book, url: "#", html: {data: {reflex_root: "#new_book"}} do |f| %>
                <div class="tab-content mt-4">
                  <div class="tab-pane fade <%= "show active" if @current_step == 1 %>">
                    <%= f.label :author, class: "form-label" %>
                    <%= f.text_field :author, class: "form-control" %>
                  </div>
                  <div class="tab-pane fade <%= "show active" if @current_step == 2 %>">
                    <%= f.label :title, class: "form-label" %>
                    <%= f.text_field :title, class: "form-control" %>
                  </div>
                  <div class="tab-pane fade <%= "show active" if @current_step == 3 %>">
                    <%= f.label :pages, class: "form-label" %>
                    <%= f.number_field :pages, class: "form-control" %>
                  </div>
                </div>
                
                <%= f.submit class: "btn btn-outline-success mt-5", disabled: @current_step != 3 %>
              <% end %>
            </div>
          </div>
        </body>
      </html>
    HTML
  end
  
  private
  
  def book_params
    params.require(:book).permit(:author, :title, :pages)
  end
end