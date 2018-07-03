ExUnit.start()

Application.ensure_all_started(:bypass)

Mox.defmock(HistogramMock, for: HTTProm.Histogram)
Mox.defmock(CounterMock, for: HTTProm.Counter)
