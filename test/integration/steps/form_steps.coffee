_      = require('lodash')

module.exports = ->
  world = this

  @Given /^I click submit$/, ->
    new this.Widgets.SimpleForm().submitForm()

  @Given /^I enter information and submit$/, ->
    form = new this.Widgets.SimpleForm()
    form.enter()

  @Then /^I should see "([^"]*)"$/, (text) ->
    div = new this.Widgets.Div()
    div.getText().should.eventually.eql(text)

  @Given /^I fill a form with:$/, (table) ->
    F = world.Widget.Form.extend({
     root: 'form'
     fields: _.pluck(table.hashes(), "name")
    })

    new F().submitWith(_.object(table.raw().slice(1)))

  @Then /^the widget should use the default form selector to find the first available form element$/, ->
    new @Widget.Form().getAttribute("class").should.eventually.eql("formula_1")

  @Then /^the widget should find the form with the supplied selector of "([^"]*)"$/,  (selector) ->
    new @Widget.Form({root: selector}).getAttribute("id").should.eventually.eql("form")

  @When /^I search for a nested option I should find it$/, ->
    new @Widget({
      root: "select"
    }).find("[value=\"wow3\"]").then (el) ->
      el.getText().then (val) ->
        val.should.eql("three")

  @When /^I select an option by value$/, ->
    _this = this
    new @Widget.Form({
      root: "select"
    })
    .select({value:"wow2"}).then ->
      new _this.Widget({
        root: '#onClick'
      })
      .read()
      .should.eventually.eql('two')

  @When /^I select an option by text$/, ->
    _this = this
    new @Widget.Form({
      root: "select"
    })
    .select({text:"three"})
    .then ->
      new _this.Widget({
        root: '#onClick'
      })
      .read()
      .should.eventually.eql('three')
