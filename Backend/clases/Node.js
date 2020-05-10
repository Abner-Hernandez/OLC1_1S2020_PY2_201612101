
class Node {

    constructor(_value,_row,_column) {
        this.value = _value;
        this.row = _row;
        this.column = _column;
        this.children = [];
    }

    addNode(node){
        this.children.push(node);
    }
}

module.exports = Node;