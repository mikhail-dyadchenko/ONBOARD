class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    admins    = [ "superadmin", "admin" ]
    redactors = [ "superadmin", "admin", "redactor" ]
    authors   = [ "superadmin", "admin", "redactor", "author" ]
    civils    = [                                   "author", "user" ]
    roles     = [ "superadmin", "admin", "redactor", "author", "user" ]

    user.role == "superadmin" ? (can [ :read, :manage ], :all) : (cannot [ :read, :manage ], :all)


    # Basic rules for admins

    if admins.include?(user.role)
      cannot :edit, User, role: "superadmin"
      can    :edit, User, { id: user.id, role: "superadmin" }
      can    :edit, User, { id: user.id, role: "admin" }
      can    :edit, User, role: "redactor"
      can    :edit, User, role: "author"
      can    :edit, User, role: "user"
      can    :index, User

      cannot :change_contributor_status, User, role: "superadmin"
      can    :change_contributor_status, User, { id: user.id, role: "superadmin" }
      can    :change_contributor_status, User, { id: user.id, role: "admin" }
      can    :change_contributor_status, User, role: "redactor"
      can    :change_contributor_status, User, role: "author"
      can    :change_contributor_status, User, role: "user"

      # can    :index, Invite
      # can    :manage, Invite
      can    :manage, List
      can    :manage, Tag
      can    :manage, Tagging
    end


    # Basic rules for redactors

    if redactors.include?(user.role)
      can :manage, [ Publication, Comment, Tag ]
      can [ :edit, :update ], StaticPage
      can :accept, AuthorshipRequest
      # can :accepted, AuthorshipRequestMailer
    end


    # Basic rules for authors

    if authors.include?(user.role)
      can [ :new, :create ], Publication
      can [ :edit, :update, :destroy ], Publication, user_id: user.id
      can [ :create, :update, :destroy ], [ PublicationImage, TeaserImage, Video ]
      can :mark_to_destroy, PublicationImage

      # ???
      can [ :create, :update, :destroy ], [ PublicationImage, TeaserImage, Video ]
      can [ :publication_tags, :places ], Tagging
    end


    # Basic rules for all registered users

    if roles.include?(user.role)
      cannot :password, User
      can :password, User, id: user.id
      can :update, User, id: user.id
      can [ :show, :contributors, :all_publications ], User
      can [ :index, :by_date, :by_rating, :s ], Publication
      can [ :show, :best, :feed ], Post
      can [ :show, :poster ], Event
      can :send_to_email, Invite
      can :new, AuthorshipRequest
      can [ :read, :create ], Comment
      can :show, [ Tag, StaticPage ]
      can [ :error_404, :error_500 ], Error
      # can '/errors/error_404'
      # can '/errors/error_500'

      # ???
      # can :read, [Publication, Post, Event]
    end

    can :index, User if user.role == "redactor"


    # Basic rules for all not administrative users

    if civils.include?(user.role)
      cannot :read, Comment, blocked: true
    end


    # Rules for Guests

    if user.id.nil?
      can [ :show, :contributors, :all_publications ], User
      # can [:index, :new, :by_date, :by_rating, :s], Publication
      can [ :show, :best, :feed ], Post
      can [ :show, :poster ], Event
      can :read, Comment
      cannot :read, Comment, blocked: true
      can :show, [ Tag, StaticPage ]
      can [ :error_404, :error_500 ], Error
      # can :create, InviteRequest
      # TODO comment this if Invite only access
      can :create, User
      # can :create, Devise::PasswordsController
    end

    can [ :index, :by_date, :by_rating, :s ], Publication
  end
end
