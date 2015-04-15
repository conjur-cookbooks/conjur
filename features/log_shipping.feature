@container
Feature: Log shipping

  After running the cookbook, events such as logging in and out are
  reported back to the Conjur server to be stored in the permanent audit record.

  Scenario: Logging in
    Given a configured machine
    When a user logs in
    Then an audit record is created
