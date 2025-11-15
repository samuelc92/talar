defmodule Talar.Accounts.UserNotifier do
  import Swoosh.Email

  alias Talar.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"No Reply", "no-reply@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """
    Hi #{user.username},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    Thanks,
    Your Talar Team
    """)
  end

  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """
    Hi #{user.name},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this, please ignore this email.

    Thanks,
    Your Talar Team
    """)
  end

  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """
    Hi #{user.name},

    You can update your email by visiting the URL below:

    #{url}

    If you didn't request this, please ignore this email.

    Thanks,
    Your Talar Team
    """)
  end
end
