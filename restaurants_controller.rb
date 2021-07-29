class RestaurantsController < ApplicationController
  def new
    @current_step ||= 1
    
    # empty state initialization
    @restaurant = session.fetch(:new_restaurant, Restaurant.new(name: "Antonio's", rating: 1))
    
    render inline: <<~HTML
      <html>
        <head>
          <title>Restaurant Wizard Demo</title>
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
          <%= javascript_include_tag "/index.js", type: "module" %>
        </head>
        <body>
          <nav class="navbar navbar-expand-lg navbar-light bg-light">
            <div class="container-fluid">                            
              <ul class="navbar-nav">
                <li class="nav-item">
                  <a class="nav-link" href="/books/new">New Book</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link active" href="/restaurants/new">New Restaurant</a>
                </li>
              </ul>              
            </div>
          </nav>
          
          <div class="container my-5">
            <h1>Restaurant Wizard</h1>
            
            <h3 class="mt-4">New Restaurant</h3>
            <div data-step="<%= @current_step %>">
              <ul class="nav nav-pills nav-justified">
                <li class="nav-item">
                  <a class="nav-link <%= 'disabled' if @current_step < 1 %> <%= 'active' if @current_step == 1 %>" aria-current="page" href="#">Name</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link <%= 'disabled' if @current_step < 2 %> <%= 'active' if @current_step == 2 %>" href="#">Rating</a>
                </li>
              </ul>
              
              <div class="btn-group mt-4" role="group" aria-label="Basic outlined example">
                <button type="button" class="btn btn-outline-primary" data-reflex="click->RestaurantWizard#refresh" data-incr="-1" data-reflex-form-selector="#new_restaurant" data-reflex-dataset="combined" <%= 'disabled' if @current_step == 1 %>>Previous</button>
                <button type="button" class="btn btn-outline-primary" data-reflex="click->RestaurantWizard#refresh" data-incr="1" data-reflex-form-selector="#new_restaurant" data-reflex-dataset="combined" <%= 'disabled' if @current_step == 2 %>>Next</button>
              </div>
              
              <%= form_for @restaurant, url: "#", html: {data: {reflex_root: "#new_restaurant"}} do |f| %>
                <div class="tab-content mt-4">
                  <div class="tab-pane fade <%= "show active" if @current_step == 1 %>">
                    <%= f.label :name, class: "form-label" %>
                    <%= f.text_field :name, class: "form-control" %>
                  </div>
                  <div class="tab-pane fade <%= "show active" if @current_step == 2 %>">
                    <%= f.label :rating, class: "form-label" %>
                    <%= f.number_field :rating, class: "form-control" %>
                  </div>
                </div>
                
                <%= f.submit class: "btn btn-outline-success mt-5", disabled: @current_step != 2 %>
              <% end %>
            </div>
          </div>
        </body>
      </html>
    HTML
  end
  
  private
  
  def restaurant_params
    params.require(:restaurant).permit(:name, :rating)
  end
end