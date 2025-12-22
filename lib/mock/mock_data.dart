import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/idea.dart';
import '../models/topic.dart';

sealed class MockData {
  static const topics = <Topic>[
    Topic(id: 'scifi', name: 'Science Fiction', icon: Icons.auto_awesome),
    Topic(id: 'strategy', name: 'Strategy', icon: Icons.grid_view),
    Topic(id: 'writing', name: 'Reading & Writing', icon: Icons.edit_note),
    Topic(id: 'time', name: 'Time Management', icon: Icons.schedule),
    Topic(id: 'psych', name: 'Psychology', icon: Icons.psychology),
    Topic(id: 'biz', name: 'Business', icon: Icons.bar_chart),
  ];

  static const articles = <Article>[
    Article(
      id: 'a1',
      title: 'Build systems that don\'t require motivation',
      author: 'J. Harper',
      source: 'Openstash Daily',
      reads: 18204,
      ideas: <Idea>[
        Idea(
          id: 'a1_i1',
          text: 'Motivation is a spark; systems are a fuel line. Design routines that run even on low-energy days.',
        ),
        Idea(
          id: 'a1_i2',
          text: 'Make the first step tiny. If the smallest version is easy, consistency becomes inevitable.',
        ),
        Idea(
          id: 'a1_i3',
          text: 'Remove friction before you add features: prepare tools, reduce choices, and pre-commit time.',
        ),
      ],
    ),
    Article(
      id: 'a2',
      title: 'Why reading changes your decision-making faster than experience',
      author: 'S. Lin',
      source: 'Idea Notes',
      reads: 9341,
      ideas: <Idea>[
        Idea(
          id: 'a2_i1',
          text: 'Books compress decades of trial-and-error into hours, letting you borrow patterns without paying the full price.',
        ),
        Idea(
          id: 'a2_i2',
          text: 'Good writing gives you mental models—experience only gives you stories.',
        ),
        Idea(
          id: 'a2_i3',
          text: 'If you extract ideas into your own words, you turn passive reading into reusable tools.',
        ),
      ],
    ),
    Article(
      id: 'a3',
      title: 'The overlooked skill: thinking in constraints',
      author: 'M. Ortega',
      source: 'Deep Worklight',
      reads: 12011,
      ideas: <Idea>[
        Idea(
          id: 'a3_i1',
          text: 'Constraints are not limits; they are design inputs that reduce ambiguity and accelerate decisions.',
        ),
        Idea(
          id: 'a3_i2',
          text: 'The best plans start with what cannot change, then optimize what can.',
        ),
      ],
    ),
  ];
}
