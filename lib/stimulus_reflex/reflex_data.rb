# frozen_string_literal: true

class StimulusReflex::ReflexData
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def reflex_name
    reflex_name = target.split("#").first
    reflex_name = reflex_name.camelize
    reflex_name.end_with?("Reflex") ? reflex_name : "#{reflex_name}Reflex"
  end

  def selectors
    selectors = (data["selectors"] || []).select(&:present?)
    selectors = data["selectors"] = ["body"] if selectors.blank?
    selectors
  end

  def target
    data["target"].to_s
  end

  def method_name
    target.split("#").second
  end

  def arguments
    (data["args"] || []).map { |arg| object_with_indifferent_access arg } || []
  end

  def url
    data["url"].to_s
  end

  def element
    StimulusReflex::Element.new(data)
  end

  def permanent_attribute_name
    data["permanentAttributeName"]
  end

  def suppress_logging
    data["suppressLogging"]
  end

  def form_data
    Rack::Utils.parse_nested_query(data["formData"])
  end

  def params
    form_params.deep_merge(url_params)
  end

  def form_params
    form_data.deep_merge(data["params"] || {})
  end

  def url_params
    Rack::Utils.parse_nested_query(URI.parse(url).query)
  end

  def id
    data["id"]
  end

  def tab_id
    data["tabId"]
  end

  # TODO: remove this in v4
  def xpath_controller
    data["xpathController"]
  end

  def xpath_element
    data["xpathElement"]
  end
  # END TODO remove

  def reflex_controller
    data["reflexController"]
  end

  def npm_version
    data["version"].to_s
  end

  def version
    data["version"].to_s.gsub("-pre", ".pre").gsub("-rc", ".rc")
  end

  private

  def object_with_indifferent_access(object)
    return object.with_indifferent_access if object.respond_to?(:with_indifferent_access)
    object.map! { |obj| object_with_indifferent_access obj } if object.is_a?(Array)
    object
  end
end
