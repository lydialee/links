$ ->
  # View define
  Todo = Backbone.Model.extend

    defaults: ->
      title: 'empty todo...',
      done: false,
      order: Todos.nextOrder()

    # toggle the done state of an item
    toggle: -> this.save({done: !this.get('done')})

  # Collection
  TodoList = Backbone.Collection.extend
    model: Todo,

    localStorage: new Backbone.LocalStorage('todos-backbone'),  # localStorage

    done: -> this.where({done: true}) # where�൱��filter���ҳ�collection������match�Ķ���
    remaining: -> this.where({done: false})
    # ��������
    nextOrder: ->
        if !this.length
          1
        else
          this.last().get('order') + 1
    comparator: 'order' # ���������

  Todos = new TodoList

  TodoView = Backbone.View.extend({
    tagName: 'li',

    template: _.template($('#item-template').html()), # Ҫrepeat��Ԫ��ģ��

    events:
      'click .toggle': 'toggleDone' # ����л�������δ��״̬
      'dbclick .view': 'edit' # ˫�����༭��Ŀ
      'click a.destroy': 'clear' # ��������Ŀ
      'keypress .edit': 'updateOnEnter' # �༭��Ŀ�󣬻س�����
      'blur .edit': 'close' # �༭��Ŀ��ʧ������

    initialize: ->
      this.listenTo(this.model, 'change', this.render) # ʱ�������model�仯ʱ������Ⱦ��
      this.listenTo(this.model, 'destroy', this.remove) # �����Ŀʱ����remove

    render: ->
      this.$el.html(this.template(this.model.toJSON()))
      this.$el.toggleClass('done', this.model.get('done'))
      this.input = this.$('.edit')
      this

    toggleDone: -> this.model.toggle()

    edit: ->
      this.$el.addClass('editing')
      this.input.focus()

    close: ->
      value = this.input.val()
      if !value
        this.clear() # ���û���ݣ�ɾ������
      else
        this.model.save({title: value})
        this.$el.removeClass('editing')


    updateOnEnter: (e) ->
      if e.keyCode == 13
        this.close() # ��������close����

    clear: -> this.model.destroy()
  })

  # our overall AppView is the top-level piece of UI
  AppView = Backbone.View.extend({
    el: $('#todoapp')

    statsTemplate: _.template($('#stats-template').html())

    events:
      'keypress #new-todo': 'createOnEnter' # �س����洴������Ŀ
      'click #clear-completed': 'clearCompleted' # ���������
      'click #toggle-all': 'toggleAllComplete' # �������Ϊ����

    initialize: ->
      this.input = this.$('#new-todo')
      this.allCheckbox = this.$('#toggle-all')[0]

      this.listenTo(Todos, 'add', this.addOne)
      this.listenTo(Todos, 'reset', this.addAll)
      this.listenTo(Todos, 'all', this.render)

      this.footer = this.$('footer')
      this.main = this.$('#main')

      Todos.fetch()

    render: ->
      done = Todos.done().length
      remaining = Todos.remaining().length
      if Todos.length
        this.main.show()
        this.footer.show()
        this.footer.html(this.statsTemplate({done: done, remaining: remaining}))
      else
        this.main.hide()
        this.footer.hide()

    addOne: (todo) ->
      view = new TodoView({model: todo}) # createһ�Σ���һ��view
      this.$('#todo-list').append(view.render().el)

    addAll: -> Todos.each(this.addOne, this) # ?

    createOnEnter: (e) ->
      if e.keyCode != 13
        return
      if !this.input.val()
        return

      Todos.create({title: this.input.val()});
      this.input.val('')

    clearCompleted: ->
      _.invoke(Todos.done(), 'destroy')
      false

    # toggle��ѡȫ��
    toggleAllComplete: ->
      done = this.allCheckbox.checked
      Todos.each((todo) -> todo.save({'done': done}))
  })

  App = new AppView