var LoginForm = React.createClass({
render: function() {
    return (
      <form className="LoginForm" action="/" method="POST">
      <table border="1">
        <thead>
          <tr><th colspan="2">User Authentication</th></tr>
        </thead>
        <tbody>
            <tr>
              <td>Username: </td>
              <td><input type="text" name="username" placeholder="Type username..." /></td>
            </tr>
            <tr>
              <td>Password: </td>
              <td><input type="password" name="password" placeholder="Type secret pass..." /></td>
            </tr>
            <tr>
              <td colspan="2"><input type="submit" name="submit" value="Login" /></td>
            </tr>
        </tbody>
      </table>
      </form>
    );
  }
});
React.render(
  React.createElement(LoginForm, null),
  document.getElementById('content')
);
