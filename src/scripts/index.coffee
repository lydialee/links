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

    done: -> this.where({done: true}) # where相当于filter，找出collection中所有match的对象
    remaining: -> this.where({done: false})
    # 用来排序
    nextOrder: ->
        if !this.length
          1
        else
          this.last().get('order') + 1
    comparator: 'order' # 排序的依据

  Todos = new TodoList

  TodoView = Backbone.View.extend({
    tagName: 'li',

    template: _.template($('#item-template').html()), # 要repeat的元素模板

    events:
      'click .toggle': 'toggleDone' # 点击切换已做与未做状态
      'dblclick .view': 'edit' # 双击，编辑条目
      'click a.destroy': 'clear' # 点击叉掉条目
      'keypress .edit': 'updateOnEnter' # 编辑条目后，回车保存
      'blur .edit': 'close' # 编辑条目的失焦保存

    initialize: ->
      this.listenTo(this.model, 'change', this.render) # 时间监听，model变化时重新渲染；
      this.listenTo(this.model, 'destroy', this.remove) # 叉掉条目时触发remove

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
        this.clear() # 如果没内容，删掉这条
      else
        this.model.save({title: value})
        this.$el.removeClass('editing')


    updateOnEnter: (e) ->
      if e.keyCode == 13
        this.close() # 调用自身close方法

    clear: -> this.model.destroy()
  })

  # our overall AppView is the top-level piece of UI
  AppView = Backbone.View.extend({
    el: $('#todoapp')

    statsTemplate: _.template($('#stats-template').html())

    events:
      'keypress #new-todo': 'createOnEnter' # 回车保存创建的条目
      'click #clear-completed': 'clearCompleted' # 清除已做的
      'click #toggle-all': 'toggleAllComplete' # 标记所有为已做

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
      view = new TodoView({model: todo}) # create一次：加一个view
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

    # toggle勾选全部
    toggleAllComplete: ->
      done = this.allCheckbox.checked
      Todos.each((todo) -> todo.save({'done': done}))
  })

  App = new AppView