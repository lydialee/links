$(function() {

    // View define
    var Todo = Backbone.Model.extend({

        defaults: function() {
            return {
                title: 'empty todo...',
                done: false,
                order: Todos.nextOrder()
            }
        },

        // toggle the done state of an item
        toggle: function() {
            this.save({done: !this.get('done')})
        }

    })

    // Collection
    var TodoList = Backbone.Collection.extend({

        model: Todo,

        localStorage: new Backbone.LocalStorage('todos-backbone'),  //??

        done: function() {
            return this.where({done: true}) // where相当于filter，找出collection中所有match的对象
        },

        remaining: function() {
            return this.where({done: false})
        },

        // 用来排序
        nextOrder: function() {
            if (!this.length) return 1
            return this.last().get('order') + 1
        },

        comparator: 'order' // 排序的依据

    })

    var Todos = new TodoList

    var TodoView = Backbone.View.extend({
        tagName: 'li',

        template: _.template($('#item-template').html()), // 要repeat的元素模板

        events: {
            'click .toggle': 'toggleDone', // 点击切换已做与未做状态
            'dblclick .view': 'edit', // 双击，编辑条目
            'click a.destroy': 'clear', // 点击叉掉条目
            'keypress .edit': 'updateOnEnter', // 编辑条目后，回车保存
            'blur .edit': 'close' // 编辑条目的失焦保存
        },

        initialize: function() {
            this.listenTo(this.model, 'change', this.render) // 时间监听，model变化时重新渲染；
            this.listenTo(this.model, 'destroy', this.remove) // 叉掉条目时触发remove
        },

        render: function() {
            this.$el.html(this.template(this.model.toJSON()))
            this.$el.toggleClass('done', this.model.get('done'))
            this.input = this.$('.edit')
            return this
        },

        toggleDone: function() {
            this.model.toggle()
        },

        edit: function() {
            this.$el.addClass('editing')
            this.input.focus()
        },

        close: function() {
            var value = this.input.val()
            if (!value) {
                this.clear() // 如果没内容，删掉这条
            } else {
                this.model.save({title: value})
                this.$el.removeClass('editing')
            }
        },

        updateOnEnter: function(e) {
            if (e.keyCode === 13) {
                this.close() // 调用自身close方法
            }
        },

        clear: function() {
            this.model.destroy()
        }
    })

    // our overall AppView is the top-level piece of UI
    var AppView = Backbone.View.extend({
        el: $('#todoapp'),

        statsTemplate: _.template($('#stats-template').html()),

        events: {
            'keypress #new-todo': 'createOnEnter', // 回车保存创建的条目
            'click #clear-completed': 'clearCompleted', // 清除已做的
            'click #toggle-all': 'toggleAllComplete' // 标记所有为已做
        },

        initialize: function() {
            this.input = this.$('#new-todo')
            this.allCheckbox = this.$('#toggle-all')[0]

            this.listenTo(Todos, 'add', this.addOne)
            this.listenTo(Todos, 'reset', this.addAll)
            this.listenTo(Todos, 'all', this.render)

            this.footer = this.$('footer')
            this.main = this.$('#main')

            Todos.fetch()
        },

        render: function() {
            var done = Todos.done().length
            var remaining = Todos.remaining().length
            if (Todos.length) {
                this.main.show()
                this.footer.show()
                this.footer.html(this.statsTemplate({done: done, remaining: remaining}))
            } else {
                this.main.hide()
                this.footer.hide()
            }
        },

        addOne: function(todo) {
            var view = new TodoView({model: todo}) // create一次：加一个view
            this.$('#todo-list').append(view.render().el)
        },

        addAll: function() {
            Todos.each(this.addOne, this) // ?
        },

        createOnEnter: function(e) {
            if (e.keyCode !== 13) return
            if (!this.input.val()) return

            Todos.create({title: this.input.val()});
            this.input.val('')
        },

        clearCompleted: function() {
            _.invoke(Todos.done(), 'destroy')
            return false
        },

        // toggle勾选全部
        toggleAllComplete: function() {
            var done = this.allCheckbox.checked
            Todos.each(function(todo) { todo.save({'done': done}) })
        }
    })

    var App = new AppView

})

















