package Example;
use Dancer2;
use DBI;
use Digest::SHA qw(sha256_hex);

our $VERSION = '0.1';

# Database connection
sub get_dbh {
    my $dbh = DBI->connect(
        config->{database}->{dsn},
        config->{database}->{username},
        config->{database}->{password},
        { RaiseError => 1, PrintError => 0, AutoCommit => 1 }
    );
    return $dbh;
}

get '/' => sub {
    template 'index' => { 'title' => 'Example' };
};

get '/register' => sub {
    # Render the registration form template
    template 'register' => { 'title' => 'Register' };
};

post '/register' => sub {
    # Implement user registration logic here
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    my $confirm_password = body_parameters->get('confirm_password');
    my $email = body_parameters->get('email');
    
    # Check if passwords match
    if ($password ne $confirm_password) {
        return template 'register' => { 'title' => 'Register', 'error' => 'Passwords do not match' };
    }
    
    # Encrypt the password
    my $encrypted_password = sha256_hex($password);
    
    # Add user registration logic (e.g., save user to database)
    my $dbh = get_dbh();
    eval {
        my $sth = $dbh->prepare('INSERT INTO users (username, password, email) VALUES (?, ?, ?)');
        $sth->execute($username, $encrypted_password, $email);
    };
    if ($@) {
        return template 'register' => { 'title' => 'Register', 'error' => 'Failed to register user' };
    }
    
    # Redirect to login page after successful registration
    redirect '/login';
};

get '/login' => sub {
    # Render the login form template
    template 'login' => { 'title' => 'Login' };
};

post '/login' => sub {
    # Implement user login logic here
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    
    # Add user login logic (e.g., authenticate user)
    my $dbh = get_dbh();
    my $sth = $dbh->prepare('SELECT password FROM users WHERE username = ?');
    $sth->execute($username);
    my ($stored_password) = $sth->fetchrow_array();
    
    if ($stored_password && $stored_password eq sha256_hex($password)) {
        # Redirect to home page after successful login
        redirect '/';
    } else {
        return template 'login' => { 'title' => 'Login', 'error' => 'Invalid username or password' };
    }
};

true;
