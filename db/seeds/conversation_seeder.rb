# Custom conversation seeder to create multiple sample conversations
class ConversationSeeder
  def self.seed!
    return if Rails.env.production?
    
    account = Account.first
    return unless account
    
    user = User.first
    inbox = Inbox.first
    return unless user && inbox
    
    # Create 10 additional conversations with different scenarios
    10.times do |i|
      contact_inbox = ContactInboxWithContactBuilder.new(
        source_id: "customer_#{i + 2}",
        inbox: inbox,
        hmac_verified: true,
        contact_attributes: { 
          name: "Customer #{i + 2}", 
          email: "customer#{i + 2}@example.com", 
          phone_number: "+232000#{i + 2}" 
        }
      ).perform

      conversation = Conversation.create!(
        account: account,
        inbox: inbox,
        status: [:open, :resolved, :pending].sample,
        assignee: [user, nil].sample,
        contact: contact_inbox.contact,
        contact_inbox: contact_inbox,
        additional_attributes: {},
        created_at: rand(30.days).seconds.ago
      )

      # Create different types of conversations
      case i % 5
      when 0
        create_support_conversation(conversation, contact_inbox)
      when 1
        create_sales_conversation(conversation, contact_inbox)
      when 2
        create_billing_conversation(conversation, contact_inbox)
      when 3
        create_technical_conversation(conversation, contact_inbox)
      when 4
        create_feedback_conversation(conversation, contact_inbox)
      end
    end

    puts "✅ Created 10 additional sample conversations"
  end

  private

  def self.create_support_conversation(conversation, contact_inbox)
    messages = [
      "Hi, I'm having trouble with my account login",
      "I keep getting an error message when I try to sign in",
      "Can you help me reset my password?",
      "Thank you for your help!"
    ]
    
    create_conversation_messages(conversation, contact_inbox, messages, "Support Issue")
  end

  def self.create_sales_conversation(conversation, contact_inbox)
    messages = [
      "Hello, I'm interested in your premium plan",
      "What features are included in the enterprise package?",
      "Can I get a demo of the platform?",
      "When can we schedule a call?"
    ]
    
    create_conversation_messages(conversation, contact_inbox, messages, "Sales Inquiry")
  end

  def self.create_billing_conversation(conversation, contact_inbox)
    messages = [
      "I have a question about my recent invoice",
      "There seems to be an extra charge I don't recognize",
      "Can you explain what this fee is for?",
      "I'd like to update my payment method"
    ]
    
    create_conversation_messages(conversation, contact_inbox, messages, "Billing Question")
  end

  def self.create_technical_conversation(conversation, contact_inbox)
    messages = [
      "The API is returning a 500 error",
      "I'm trying to integrate with your webhook system",
      "The documentation mentions rate limits, what are they?",
      "Is there a way to increase the API quota?"
    ]
    
    create_conversation_messages(conversation, contact_inbox, messages, "Technical Support")
  end

  def self.create_feedback_conversation(conversation, contact_inbox)
    messages = [
      "I love the new dashboard design!",
      "The recent updates have made everything much faster",
      "One suggestion: could you add dark mode?",
      "Overall, great work on the improvements"
    ]
    
    create_conversation_messages(conversation, contact_inbox, messages, "Product Feedback")
  end

  def self.create_conversation_messages(conversation, contact_inbox, messages, subject)
    # Add subject as first message if provided
    if subject
      Message.create!(
        content: "Subject: #{subject}",
        account: conversation.account,
        inbox: conversation.inbox,
        conversation: conversation,
        sender: contact_inbox.contact,
        message_type: :incoming,
        created_at: conversation.created_at
      )
    end

    messages.each_with_index do |content, index|
      Message.create!(
        content: content,
        account: conversation.account,
        inbox: conversation.inbox,
        conversation: conversation,
        sender: index.even? ? contact_inbox.contact : conversation.assignee,
        message_type: index.even? ? :incoming : :outgoing,
        created_at: conversation.created_at + (index * 10).minutes
      )
    end

    # Add some sample template messages randomly
    if rand(3) == 0
      Seeders::MessageSeeder.create_sample_csat_collect_message(conversation)
    end
  end
end

# Run the seeder
ConversationSeeder.seed!
