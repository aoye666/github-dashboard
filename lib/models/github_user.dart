import 'package:flutter/material.dart';

/// GitHub 用户模型
class GitHubUser {
  final String login;
  final int id;
  final String avatarUrl;
  final String? name;
  final String? bio;
  final String? company;
  final String? location;
  final String? email;
  final String? blog;
  final String? twitterUsername;
  final int publicRepos;
  final int publicGists;
  final int followers;
  final int following;
  final DateTime createdAt;
  final DateTime updatedAt;

  GitHubUser({
    required this.login,
    required this.id,
    required this.avatarUrl,
    this.name,
    this.bio,
    this.company,
    this.location,
    this.email,
    this.blog,
    this.twitterUsername,
    required this.publicRepos,
    required this.publicGists,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] ?? '',
      id: json['id'] ?? 0,
      avatarUrl: json['avatar_url'] ?? '',
      name: json['name'],
      bio: json['bio'],
      company: json['company'],
      location: json['location'],
      email: json['email'],
      blog: json['blog'],
      twitterUsername: json['twitter_username'],
      publicRepos: json['public_repos'] ?? 0,
      publicGists: json['public_gists'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get displayName => name ?? login;
}
