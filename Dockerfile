FROM ruby:3.3.4

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Ruby
COPY Gemfile Gemfile.lock ./

COPY decidim-auth-ldap/decidim-auth-ldap.gemspec ./decidim-auth-ldap/

RUN bundle install

# required by decidim:0.30.5
RUN npm i -g yarn

# Node
COPY package.json package-lock.json ./

RUN npm install

COPY . .

# Assets
RUN bin/rails assets:precompile

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]