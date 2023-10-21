function handleTodoChange(element, index) {
    // Send AJAX request to update the todo's completion status
    fetch(`/toggle_todo/${index}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            completed: element.checked
        })
    }).then(response => response.json()).then(data => {
        // You can do something with the response here if you wish
        console.log(data);
        alert('Todo updated successfully!');
    }).catch((error) => {
        console.error('Error:', error);
        alert('There was an error updating the todo. Please try again.');
    });
}
