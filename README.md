Write powerful wizards using page morphs

**How?**
- An empty state model is memoized in the controller (`@book ||= Book.new(title: ...)`)
- A general purpose `WizardReflex` is used to step through the wizard and perist the model's state in the `session`
- A `@current_step` variable is in/decreased to display the current wizard pane.
- Validations are performed contextually, i.e. `on: :step_1`, etc.
- An _allowlist_ approach is used to centrally sanitize resource classes and strong params in that reflex.

**Caveat**

In these examples, the amount of `steps` per wizard are hardcoded.

**Variations**

Enrich individual `WizardReflexes` with custom input processing logic:

```rb
class WizardReflex < ApplicationReflex
  def refresh
    additional_attributes, processed_resource_params = yield(resource_params) if block_given?

    session[:"new_#{resource_name.underscore}"] = resource_class.new(processed_resource_params || resource_params)
    session[:"new_#{resource_name.underscore}"].assign_attributes(**additional_attributes || {})

    # ...
  end
  
  # ...
end

class BookReflex < WizardReflex
  def refresh
    super do |params|
      [{isbn: '1234'}, params.except(...)]
    end
  end
end
```
