class IndividualCandidate {
  final String candidateId;
  final String title;
  final int eventCount;
  final List<String> eventIds;

  const IndividualCandidate({
    required this.candidateId,
    required this.title,
    required this.eventCount,
    required this.eventIds,
  });
}
