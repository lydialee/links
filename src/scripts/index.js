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

        LocalStorage: new Backbone.LocalStorage('todos-backbone'),  //??

        done: function() {
            return this.where({done: true})
        },

        remaining: function() {
            return this.where({done: false})
        },

        // 要这个干嘛
        nextOrder: function() {
            // ...
        },

        comparator: 'order'

    })

    var Todos = new TodoList;

    var TodoView = Backbone.View.extend({
        tagName: 'li',

        template: _.template()
    })

})









