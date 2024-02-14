resource "aws_key_pair" "ec2_keypair" {
  key_name   = "sensible-ec2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgGJ5FfsDSaeiUfJsSIGPTiN+wX775i3YtLSrSUal+Ic6Neh+bHNAJWwnaMI4nhwurzdeAiwsDTbkGnZg1eyxaFYz8xLe/ra/yHHijlxaOLCoGkGPbjkWrhR0nON7hF0sjQmF9Y8kZvofmcaLsnbaJZogEFK4wuVPziTRhSu69cJ6MDCf/aSlUpbJltNn96qb2nB/ywoymDE6+rnPcgXzgE6vrG3p8WAVCo52C+lXsofOH925AN2TXNZ6ajFvn7o2zmyMDjgYk0HsJ64raf/XscxGUsRbc3y/ITCLkghgjjZUrwd2eC6eCWAtQD3zXGDFl4hXv926FAtaM/1fPZz0Kxtn1TK4XunfojromcA927mIYvhxMHvJdD3FpTPFy3/Y+HEF4KZW3acGpa3i5wyt7wlxY8ICgpoFVLgOLrwXgFmJCScNE+a9uN6p8Kt6vU7hNboCpF5CS/b8EyTl7dJQXkORO3ckcahLd2/n5JZ3nKpe5mSvRRjy5SO9Fz/vEkdktSyDUXFJe/+DcCNYrvspWxsXL0u4rgiqggOrnd0BeG4XFkPPIFaC+bMpjGrfkrqEi8u1cp/xhJabwsUnsq1+yhQMVAo8ROwjd7ICVvKW28rwf3yf17JxFjxMpMQKT5XtSMZcCeFNaQ5UJBxPqleH9tSZ/95RF6MtTG4B823Xp9Q== balazs.frey@snapsoft.io"
}